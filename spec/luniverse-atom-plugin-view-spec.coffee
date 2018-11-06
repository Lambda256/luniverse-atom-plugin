# 'use babel';
#
# import LuniverseAtomPluginView from '../lib/luniverse-atom-plugin-view';
#
# describe('LuniverseAtomPluginView', () => {
#   it('has one valid test', () => {
#     expect('life').toBe('easy');
#   });
# });

LuniverseSignInView = require '../lib/luniverse-atom-plugin-view'

describe "LuniverseSignInView", ->
  luniverseSignInView = null

  beforeEach ->
    luniverseSignInView = new LuniverseSignInView()

  describe "when the panel is presented", ->
    it "displays all the components", ->
      luniverseSignInView.presentPanel()

      runs ->
        expect(luniverseSignInView.questionField).toExist()
        expect(luniverseSignInView.tagsField).toExist()
