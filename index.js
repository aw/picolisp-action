  // Main required modules
var allowedArch, allowedVersions, core, defaultArch, defaultVersion, exec, init, pilPath,
  indexOf = [].indexOf;

core = require('@actions/core');

exec = require('@actions/exec');

pilPath = "https://software-lab.de";

defaultVersion = '19.6';

defaultArch = 'src64';

allowedVersions = [defaultVersion, '18.12', '18.6', '17.12', 'latest'];

allowedArch = [defaultArch, 'src'];

init = async function() {
  var arch, error, pilArchitecture, pilTarball, pilVersion, ver;
  try {
    // Set temporary variables variables (input)
    ver = (await core.getInput('version', {
      required: false
    }));
    arch = (await core.getInput('architecture', {
      required: false
    }));
    // Set internal variables
    pilVersion = indexOf.call(allowedVersions, ver) >= 0 ? ver : defaultVersion;
    pilArchitecture = indexOf.call(allowedArch, arch) >= 0 ? arch : defaultArch;
    pilTarball = pilVersion === 'latest' ? 'picoLisp.tgz' : `picoLisp-${pilVersion}.tgz`;
    console.log(`Pil ver: ${pilVersion}`);
    console.log(`Pil arch: ${pilArchitecture}`);
    // Update Ubuntu and install dependencies
    await exec.exec('sudo', ['apt-get', 'update']);
    await exec.exec('sudo', ['apt-get', 'install', 'libc6-dev-i386', 'libc6-i386', 'linux-libc-dev', 'gcc-multilib']);
    // Download and extract PicoLisp
    await exec.exec('curl', ['-o', 'picolisp.tgz', `${pilPath}/${pilTarball}`], {
      cwd: '/tmp'
    });
    await exec.exec('tar', ['-xf', 'picolisp.tgz'], {
      cwd: '/tmp'
    });
    // Build PicoLisp 32-bit
    await exec.exec('make', null, {
      cwd: '/tmp/picoLisp/src'
    });
    if (pilArchitecture === 'src64') {
      // Build PicoLisp 64-bit
      await exec.exec('make', null, {
        cwd: '/tmp/picoLisp/src64'
      });
    }
    // Install PicoLisp globally
    await exec.exec('sudo', ['ln', '-s', '/tmp/picoLisp', '/usr/lib/picolisp']);
    await exec.exec('sudo', ['ln', '-s', '/usr/lib/picolisp/bin/picolisp', '/usr/bin']);
    await exec.exec('sudo', ['ln', '-s', '/usr/lib/picolisp/bin/pil', '/usr/bin']);
    await exec.exec('sudo', ['ln', '-s', '/tmp/picoLisp', '/usr/share/picolisp']);
  } catch (error1) {
    error = error1;
    return core.setFailed(error.message);
  }
};

init();
