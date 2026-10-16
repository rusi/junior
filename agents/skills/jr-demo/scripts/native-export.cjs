const fs = require('node:fs/promises');
const path = require('node:path');
const os = require('node:os');
const { execFileSync } = require('node:child_process');
const { createHash } = require('node:crypto');
const { CaptureDirectory, capturePath, slug } = require('./capture-directory.ts');
const { captureReceipt } = require('../templates/capture-reporter.ts');
const { contactSheet } = require('./viewer.ts');
const hash = data => createHash('sha256').update(data).digest('hex');
const requireValue = (condition, message) => { if (!condition) throw new Error(message); };
function validateRun(summary) {
  requireValue(summary.result === 'Passed' && summary.totalTestCount === 1 && summary.failedTests === 0 && summary.skippedTests === 0 && summary.expectedFailures === 0,
    'Export requires one successful walkthrough with no failed, skipped or expected-failure tests.');
}
async function inspectResult(result) {
  const summary = JSON.parse(execFileSync('xcrun', ['xcresulttool','get','test-results','summary','--path',result], {encoding:'utf8'}));
  validateRun(summary);
  const directory = await fs.mkdtemp(path.join(os.tmpdir(),'native-demo-export-'));
  try {
    execFileSync('xcrun',['xcresulttool','export','attachments','--path',result,'--output-path',directory],{stdio:'pipe'});
    return {summary, directory, manifest:JSON.parse(await fs.readFile(path.join(directory,'manifest.json'),'utf8')), cleanup:()=>fs.rm(directory,{recursive:true})};
  } catch(error) { await fs.rm(directory,{recursive:true}); throw error; }
}
async function attachment(directory, name) {
  requireValue(typeof name === 'string' && name !== '.' && name !== '..' && path.basename(name) === name,'Invalid attachment path.');
  const file = path.join(directory,name);
  const metadata = await fs.lstat(file);
  requireValue(metadata.isFile(),'Attachment must be a regular file.');
  return fs.readFile(file);
}
const text = value => typeof value === 'string' && value.trim().length > 0;
async function exportCapture({result,root}, inspect = inspectResult) {
  const inspected = await inspect(result);
  try {
    validateRun(inspected.summary);
    requireValue(inspected.manifest.length === 1,'Expected exactly one test attachment group.');
    const group = inspected.manifest[0];
    const find = name => {
      const items = group.attachments.filter(a=>a.suggestedHumanReadableName.startsWith(name+'_'));
      requireValue(items.length === 1,'Missing or duplicate capture attachment: '+name);
      return items[0].exportedFileName;
    };
    const receipt = JSON.parse(await attachment(inspected.directory,find('native-storyboard')));
    requireValue(receipt.version === 1 && receipt.test === group.testIdentifier.replace(/\(\)$/, '') && text(receipt.title) && text(receipt.brief) && Array.isArray(receipt.panels) && receipt.panels.length > 0,'Invalid native storyboard receipt.');
    const names = new Set();
    const panels = [];
    for(const [i,panel] of receipt.panels.entries()) {
      requireValue(text(panel.caption) && text(panel.attachment) && !names.has(panel.attachment) && Number.isFinite(panel.focus) && panel.focus >= 0 && panel.focus <= 100,'Invalid or duplicate panel.');
      names.add(panel.attachment);
      const bytes = await attachment(inspected.directory,find(panel.attachment));
      requireValue(bytes.subarray(0,8).equals(Buffer.from([137,80,78,71,13,10,26,10])) && hash(bytes) === panel.sha256,'Changed or invalid asserted image.');
      panels.push({bytes,caption:panel.caption,image:{file:String(i+1).padStart(2,'0')+'-'+(slug(panel.caption) || 'panel')+'.png',focus:panel.focus}});
    }
    requireValue(text(group.testIdentifierURL),'Missing native test target identity.');
    const identity = 'xctest:'+group.testIdentifierURL;
    const directory = capturePath(root,receipt.title,identity);
    const output = await CaptureDirectory.open(root,directory,identity);
    try {
      for(const panel of panels) await fs.writeFile(path.join(output.directory,panel.image.file),panel.bytes);
      const index = path.join(output.directory,'index.html');
      await fs.writeFile(index,contactSheet(receipt.title,receipt.brief,panels));
      const captured = JSON.parse((await captureReceipt(index)).toString('utf8'));
      requireValue(captured.identity === identity,'Capture ownership changed before completion.');
      const marker = path.join(output.directory,'.capture-owner.json');
      await fs.writeFile(marker,JSON.stringify({identity,token:captured.token,complete:captured.files}));
      return {index,identity};
    } catch(error) { await output.remove(); throw error; }
  } finally { await inspected.cleanup(); }
}
module.exports = {exportCapture, inspectResult};
if(require.main === module) {
  const [result,root] = process.argv.slice(2);
  if(!result || !root) throw new Error('Usage: native-export.cjs RESULT.xcresult OUTPUT_ROOT');
  exportCapture({result,root}).then(value=>console.log(JSON.stringify(value))).catch(error=>{console.error(error.message);process.exitCode=1;});
}
