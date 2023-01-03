# Main required modules
core      = require '@actions/core'
exec      = require '@actions/exec'
fs        = require 'fs'

releaseVersion  = 'v3' # stable release version (git tag)
pilPath         = 'https://software-lab.de'

init = () ->
  try
    # Update Ubuntu
    await exec.exec('sudo', ['apt-get', 'update'])

    # Install dependencies
    await exec.exec('sudo', ['apt-get', 'install', 'llvm-14'])

    # Create symlinks for llvm-14 binaries
    await exec.exec('sudo', ['ln', '-s', '/usr/bin/llvm-as-14', '/usr/bin/llvm-as'])
    await exec.exec('sudo', ['ln', '-s', '/usr/bin/llvm-link-14', '/usr/bin/llvm-link'])
    await exec.exec('sudo', ['ln', '-s', '/usr/bin/llc-14', '/usr/bin/llc'])
    await exec.exec('sudo', ['ln', '-s', '/usr/bin/opt-14', '/usr/bin/opt'])

    # Download and extract pil21
    await exec.exec('curl', ['--http1.1', '-o', 'pil21.tgz', "#{pilPath}/pil21.tgz"], { cwd: '/tmp'})
    await exec.exec('tar',  ['-xf', 'pil21.tgz'],                             { cwd: '/tmp'})
    await exec.exec('mv',   ['pil21', 'picoLisp'],                            { cwd: '/tmp'})

    # Build PicoLisp
    await exec.exec('make', null, { cwd: '/tmp/picoLisp/src'})

    # Create missing pil21 pil script
    pilScript = '#!/usr/bin/picolisp /usr/lib/picolisp/lib.l\n(load "@lib/misc.l" "@lib/pilog.l")\n'
    fs.writeFileSync 'pil', pilScript, { mode: 0o755 }, (err) ->
      false
    await exec.exec('sudo', ['mv', 'pil', '/usr/bin'])

    # Install PicoLisp globally
    await exec.exec('sudo', ['ln', '-s', '/tmp/picoLisp',                   '/usr/lib/picolisp'])
    await exec.exec('sudo', ['ln', '-s', '/usr/lib/picolisp/bin/picolisp',  '/usr/bin'])
    await exec.exec('sudo', ['ln', '-s', '/tmp/picoLisp',                   '/usr/share/picolisp'])

    # Display the compiled version
    console.log "Built PicoLisp ver:"
    await exec.exec('pil',  ['-version', '-bye'])

    await return

  catch error
    core.setFailed error.message

init()
