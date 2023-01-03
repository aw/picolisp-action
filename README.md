# GitHub Action to run 64-bit pil21 PicoLisp code

This action downloads, compiles, and globally installs PicoLisp.
It can be used to run PicoLisp code such as [units tests](https://github.com/aw/picolisp-unit).

![Example PicoLisp tests](https://user-images.githubusercontent.com/153401/70022112-e4695580-158a-11ea-886d-0db01dbe7a66.png)

## Example usage

```
- uses: aw/picolisp-action@v3
- name: Print Hello World with the full PicoLisp version number
  run: pil -'prin "Hello World: "' -version -bye
```

## Example workflow

See the [picolisp-json workflow](https://github.com/aw/picolisp-json/blob/master/.github/workflows/main.yml) for a more detailed usage example.

## Code

This action is written in CoffeeScript, see [index.coffee](index.coffee)

## Notes

* Unknown values will be replaced with the default value (ex: version: 1.2.3, will become version: pil21)
* The PicoLisp environment is extracted to `/tmp/picoLisp`
* 32-bit PicoLisp is _not_ compiled anymore
* 64-bit PicoLisp which is _not_ `pil21` is _not_ compiled anymore

## Build

To build this action:

* Install `NodeJS v12`
* Install the dev dependencies with `npm install`
* Generate the `dist/index.js` with `npm run build`

## ChangeLog

* [January 3, 2023] `v3.0.0`
  - Default builds for `pil21`
  - Builds with LLVM 14
  - Removed support for 32-bit PicoLisp and 64-bit PicoLisp (except for 64-bit pil21)
* [August 28, 2020] `v2.2.0`
  - Add support for building and testing with PicoLisp 21: `pil21`
* [July 27, 2020] `v2.1.0`
  - Force `curl` to use `http1.1` when fetching the PicoLisp source code.
  - Update default PicoLisp version to 20.6

## License

[MIT License](LICENSE)

Copyright (c) 2019~ Alexander Williams, On-Prem <license@on-premises.com>
