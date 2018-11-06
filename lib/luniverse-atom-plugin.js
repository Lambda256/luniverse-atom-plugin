'use babel';

import LuniverseAtomPluginView from './luniverse-atom-plugin-view';
import { CompositeDisposable } from 'atom';

export default {

  luniverseAtomPluginView: null,
  modalPanel: null,
  subscriptions: null,

  activate(state) {
    this.luniverseAtomPluginView = new LuniverseAtomPluginView(state.luniverseAtomPluginViewState);
    this.modalPanel = atom.workspace.addModalPanel({
      item: this.luniverseAtomPluginView.getElement(),
      visible: false
    });

    // Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    this.subscriptions = new CompositeDisposable();

    // Register command that toggles this view
    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'luniverse-atom-plugin:toggle': () => this.toggle()
    }));
  },

  deactivate() {
    this.modalPanel.destroy();
    this.subscriptions.dispose();
    this.luniverseAtomPluginView.destroy();
  },

  serialize() {
    return {
      luniverseAtomPluginViewState: this.luniverseAtomPluginView.serialize()
    };
  },

  toggle() {
    console.log('LuniverseAtomPlugin was toggled!');
    return (
      this.modalPanel.isVisible() ?
      this.modalPanel.hide() :
      this.modalPanel.show()
    );
  }

};
