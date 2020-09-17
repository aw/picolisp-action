# Main required modules
core      = require '@actions/core'
exec      = require '@actions/exec'
fs        = require 'fs'

releaseVersion  = 'v2' # stable release version (git tag)
pilPath         = 'https://software-lab.de'
defaultVersion  = '20.6'
defaultArch     = 'src64'
allowedVersions = [defaultVersion, '19.12', '19.6', '18.12', '18.6', '17.12', 'latest', 'pil21']
allowedArch     = [defaultArch, 'src']

init = () ->
  try
    # Set temporary variables (input)
    ver   = await core.getInput('version',      { required: false })
    arch  = await core.getInput('architecture', { required: false })

    # Set internal variables
    pilVersion      = if ver  in allowedVersions then ver             else defaultVersion
    pilArchitecture = if arch in allowedArch     then arch            else defaultArch
    pilTarball      = if pilVersion is 'latest'  then 'picoLisp.tgz'  else "picoLisp-#{pilVersion}.tgz"

    # Update Ubuntu
    await exec.exec('sudo', ['apt-get', 'update'])

    if pilVersion is 'pil21'
      # Install dependencies
      await exec.exec('sudo', ['apt-get', 'install', 'llvm-9'])

      # Create symlinks for llvm-9 binaries
      await exec.exec('sudo', ['ln', '-s', '/usr/bin/llvm-as-9', '/usr/bin/llvm-as'])
      await exec.exec('sudo', ['ln', '-s', '/usr/bin/llvm-link-9', '/usr/bin/llvm-link'])
      await exec.exec('sudo', ['ln', '-s', '/usr/bin/llc-9', '/usr/bin/llc'])
      await exec.exec('sudo', ['ln', '-s', '/usr/bin/opt-9', '/usr/bin/opt'])

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
    else
      # Install dependencies
      await exec.exec('sudo', ['apt-get', 'install', 'libc6-dev-i386', 'libc6-i386', 'linux-libc-dev', 'gcc-multilib'])

      # Download and extract PicoLisp
      await exec.exec('curl', ['--http1.1', '-o', 'picolisp.tgz', "#{pilPath}/#{pilTarball}"], { cwd: '/tmp'})
      await exec.exec('tar',  ['-xf', 'picolisp.tgz'],                            { cwd: '/tmp'})

      # Build PicoLisp
      await exec.exec('make', null, { cwd: '/tmp/picoLisp/src'})

      # Build PicoLisp 64-bit
      await exec.exec('make', null, { cwd: '/tmp/picoLisp/src64'}) if pilArchitecture is 'src64'

    # Install PicoLisp globally
    await exec.exec('sudo', ['ln', '-s', '/tmp/picoLisp',                   '/usr/lib/picolisp'])
    await exec.exec('sudo', ['ln', '-s', '/usr/lib/picolisp/bin/picolisp',  '/usr/bin'])
    await exec.exec('sudo', ['ln', '-s', '/usr/lib/picolisp/bin/pil',       '/usr/bin']) if pilVersion isnt 'pil21'
    await exec.exec('sudo', ['ln', '-s', '/tmp/picoLisp',                   '/usr/share/picolisp'])

    # Display the compiled version
    console.log "Built PicoLisp ver:"
    await exec.exec('pil',  ['-version', '-bye'])

    await return

  catch error
    core.setFailed error.message

init()
