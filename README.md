# GitHub Action to run 32-bit or 64-bit PicoLisp code

This action downloads, compiles, and globally installs PicoLisp.
It can be used to run PicoLisp code such as [units tests](https://github.com/aw/picolisp-unit).

## Inputs

### `version`

**Optional** The version of PicoLisp. Default `19.6`. Accepts `19.6`, `18.12`, `18.6`, `17.12`, `latest`

### `architecture`

**Optional** The architecture of PicoLisp (32 or 64-bit). Default `src64`. Accepts `src`, `src64`

## Example usage

```
- uses: aw/picolisp-action@v1
  with:
    version: 18.12
    architecture: src64

- name: Run some tests
  run: |
    pil ./test.l
```

## Example workflow

See the [picolisp-json workflow](https://github.com/aw/picolisp-json/blob/master/.github/workflows/main.yml) for a more detailed usage example.

## Code

This action is written in _CoffeeScript_, see [index.coffee](index.coffee).

## Notes

* Unknown values will be replaced with the default value (ex: version: 1.2.3, will become version 19.6)
* The _PicoLisp_ environment is in extracted to `/tmp/picoLisp`
* 32-bit _PicoLisp_ is always compiled
* 64-bit _PicoLisp_ is bootstrapped from the 32-bit _PicoLisp_
* 64-bit _PicoLisp_ will not be compiled if the `architecture` value is `src`

## Build

To build this action, install `NodeJS v12` and the dev dependencies with `npm install`. Then type `npm run build` to generate the `dist/index.js`.

# License

[MIT License](LICENSE)

Copyright (c) 2019 Alexander Williams, Unscramble <license@unscramble.jp>
