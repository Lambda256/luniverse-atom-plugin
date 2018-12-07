'use babel';

import helper from '../lib/luniverse-helper-functions';
import LuniversePlugin from '../lib/luniverse-atom-plugin'
fs = require('fs')

describe('Luniverse Helper Functions', () => {
  let workspaceElement, activationPromise;

  beforeEach(() => {
    workspaceElement = atom.views.getView(atom.workspace);
    activationPromise = atom.packages.activatePackage('luniverse-atom-plugin');
  });

  it('test something', () => {
    expect(fs.existsSync(__dirname + '/testdir/ERC20Burnable.sol')).toBe(true)
    let mergePromise = helper.mergedSourceCode(__dirname + '/testdir/MainToken.sol')
      .then((result) => {
        expect(result).toBe(fs.readFileSync(__dirname + '/testdir/ERC20Burnable_pre_merged.sol', 'utf8'))
      })

    expect('easy').toBe('easy');

    waitsForPromise(() => {
      return mergePromise;
    });
  });
});
