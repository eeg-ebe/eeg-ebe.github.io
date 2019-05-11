/**
 * Copyright (c) 2009-2019, Jean-Francois Flot <http://dx.doi.org/10.1111/j.1755-0998.2009.02732.x>
 * Translated to HaXe by Yann Spoeri
 * 
 * Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is
 * hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE
 * INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF
 * USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

import haxe.ds.Vector;

/**
 * Since Haxe expects you to have classes but the original perl script doesn't contain any, there are
 * some changes in structure and code ordering. These changes are also needed because the code needs to
 * get converted into JavaScript code later on and reading / storing files works asynchronly in JavaScript
 * (which is quite different to the reading mechanisms of Perl).
 */
class SeqPhase1Result {

    private var errorsAlign1:List<String>;
    private var warningsAlign1:List<String>;

    private var errorsAlign2:List<String>;
    private var warningsAlign2:List<String>;

    private var errorsAlign3:List<String>;
    private var warningsAlign3:List<String>;

    private var errorsGeneral:List<String>;
    private var warningsGeneral:List<String>;

    private var notes:List<String>;
    private var suggestedPhaseCommand:Null<String>;

    private var varPos:Null<Int>;
    private var nbVarPos:Null<Int>;

    private var inpFile:Null<String>;
    private var knownFile:Null<String>;
    private var constFile:Null<String>;

    private static var inst:SeqPhase1Result;

    private function new() {
        clear();
    }

    public function clear():Void {
        errorsAlign1 = new List<String>();
        warningsAlign1 = new List<String>();
        errorsAlign2 = new List<String>();
        warningsAlign2 = new List<String>();
        errorsAlign3 = new List<String>();
        warningsAlign3 = new List<String>();
        errorsGeneral = new List<String>();
        warningsGeneral = new List<String>();
        notes = new List<String>();
        suggestedPhaseCommand = null;
        varPos = null;
        nbVarPos = null;
        inpFile = null;
        knownFile = null;
        constFile = null;
    }

    public function addErr(err:String, nr:Int):Void {
        if(nr == 1) {
            addAlign1Error(err);
        } else if(nr == 2) {
            addAlign2Error(err);
        } else if(nr == 3) {
            addAlign3Error(err);
        } else {
            throw "Illegal nr " + nr;
        }
    }
    public function addWrn(wrn:String, nr:Int):Void {
        if(nr == 1) {
            addAlign1Warn(wrn);
        } else if(nr == 2) {
            addAlign2Warn(wrn);
        } else if(nr == 3) {
            addAlign3Warn(wrn);
        } else {
            throw "Illegal nr " + nr;
        }
    }

    public function addAlign1Error(err:String):Void {
        errorsAlign1.add(err);
    }
    public function hasAlign1Errors():Bool {
        return errorsAlign1.length != 0;
    }
    public function getAlign1Errors():Vector<String> {
        var result:Vector<String> = new Vector<String>(errorsAlign1.length);
        var i:Int = 0;
        for(item in errorsAlign1) {
            result[i++] = item;
        }
        return result;
    }
    public function addAlign1Warn(wrn:String):Void {
        warningsAlign1.add(wrn);
    }
    public function hasAlign1Warn():Bool {
        return warningsAlign1.length != 0;
    }
    public function getAlign1Warn():Vector<String> {
        var result:Vector<String> = new Vector<String>(warningsAlign1.length);
        var i:Int = 0;
        for(item in warningsAlign1) {
            result[i++] = item;
        }
        return result;
    }
    public function addAlign2Error(err:String):Void {
        errorsAlign2.add(err);
    }
    public function hasAlign2Errors():Bool {
        return errorsAlign2.length != 0;
    }
    public function getAlign2Errors():Vector<String> {
        var result:Vector<String> = new Vector<String>(errorsAlign2.length);
        var i:Int = 0;
        for(item in errorsAlign2) {
            result[i++] = item;
        }
        return result;
    }
    public function addAlign2Warn(wrn:String):Void {
        warningsAlign2.add(wrn);
    }
    public function hasAlign2Warn():Bool {
        return warningsAlign2.length != 0;
    }
    public function getAlign2Warn():Vector<String> {
        var result:Vector<String> = new Vector<String>(warningsAlign2.length);
        var i:Int = 0;
        for(item in warningsAlign2) {
            result[i++] = item;
        }
        return result;
    }
    public function addAlign3Error(err:String):Void {
        errorsAlign3.add(err);
    }
    public function hasAlign3Errors():Bool {
        return errorsAlign3.length != 0;
    }
    public function getAlign3Errors():Vector<String> {
        var result:Vector<String> = new Vector<String>(errorsAlign3.length);
        var i:Int = 0;
        for(item in errorsAlign3) {
            result[i++] = item;
        }
        return result;
    }
    public function addAlign3Warn(wrn:String):Void {
        warningsAlign3.add(wrn);
    }
    public function hasAlign3Warn():Bool {
        return warningsAlign3.length != 0;
    }
    public function getAlign3Warn():Vector<String> {
        var result:Vector<String> = new Vector<String>(warningsAlign3.length);
        var i:Int = 0;
        for(item in warningsAlign3) {
            result[i++] = item;
        }
        return result;
    }

    public function addGeneralError(err:String):Void {
        errorsGeneral.add(err);
    }
    public function hasGeneralErrors():Bool {
        return errorsGeneral.length != 0;
    }
    public function getGeneralErrors():Vector<String> {
        var result:Vector<String> = new Vector<String>(errorsGeneral.length);
        var i:Int = 0;
        for(item in errorsGeneral) {
            result[i++] = item;
        }
        return result;
    }
    public function addGeneralWarn(wrn:String):Void {
        warningsGeneral.add(wrn);
    }
    public function hasGeneralWarn():Bool {
        return warningsGeneral.length != 0;
    }
    public function getGeneralWarn():Vector<String> {
        var result:Vector<String> = new Vector<String>(warningsGeneral.length);
        var i:Int = 0;
        for(item in warningsGeneral) {
            result[i++] = item;
        }
        return result;
    }

    public function hasErrors():Bool {
        return errorsAlign1.length > 0 || errorsAlign2.length > 0 || errorsAlign3.length > 0 || errorsGeneral.length > 0;
    }

    public function addNote(note:String):Void {
        notes.add(note);
    }
    public function hasNotes():Bool {
        return notes.length != 0;
    }
    public function getNotes():Vector<String> {
        var result:Vector<String> = new Vector<String>(notes.length);
        var i:Int = 0;
        for(item in notes) {
            result[i++] = item;
        }
        return result;
    }
    public function setSuggestedPhaseCommand(ph:String):Void {
        suggestedPhaseCommand = ph;
    }
    public function hasSuggestedCommand():Bool {
        return suggestedPhaseCommand != null;
    }
    public function getSuggestedPhaseCommand():Null<String> {
        return suggestedPhaseCommand;
    }

    public function setNrVarPos(nr:Int):Void {
        varPos = nr;
    }
    public function getNrVarPos():Int {
        return varPos;
    }
    public function setNrNbVarPos(nr:Int):Void {
        nbVarPos = nr;
    }
    public function getNrNbVarPos():Int {
        return nbVarPos;
    }

    public function setInpFile(content:String):Void {
        inpFile = content;
    }
    public function hasInpFile():Bool {
        return inpFile != null;
    }
    public function getInpFile():String {
        return inpFile;
    }
    public function setKnownFile(content:String):Void {
        knownFile = content;
    }
    public function hasKnownFile():Bool {
        return knownFile != null;
    }
    public function getKnownFile():String {
        return knownFile;
    }
    public function setConstFile(content:String):Void {
        constFile = content;
    }
    public function hasConstFile():Bool {
        return constFile != null;
    }
    public function getConstFile():String {
        return constFile;
    }

    public static function instance():SeqPhase1Result {
        if(inst == null) {
            inst = new SeqPhase1Result();
        }
        return inst;
    }

}
