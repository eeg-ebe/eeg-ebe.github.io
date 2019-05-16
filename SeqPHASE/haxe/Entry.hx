class Entry {
    private var name:String;
    private var seq:String;
    private var line:Int;

    public function new(line:Int=-1, name:String=null, seq:String=null) {
        this.line = line;
        this.name = name;
        this.seq = seq;
    }

    public function addToSeq(s:String):Void {
        if (this.seq == null || this.seq == "") {
            this.seq = s;
        } else {
            this.seq = this.seq + s;
        }
    }

    public function getName():String {
        return name;
    }

    public function getSeq():String {
        if(seq == null) return "";
        return seq;
    }

    public function getLineNo():Int {
        return line;
    }
}
