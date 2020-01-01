// Generated by Haxe 3.4.7
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var Entry = function(line,name,seq) {
	if(line == null) {
		line = -1;
	}
	this.line = line;
	this.name = name;
	this.seq = seq;
};
Entry.__name__ = true;
Entry.prototype = {
	addToSeq: function(s) {
		if(this.seq == null || this.seq == "") {
			this.seq = s;
		} else {
			this.seq += s;
		}
	}
	,getName: function() {
		return this.name;
	}
	,getSeq: function() {
		if(this.seq == null) {
			return "";
		}
		return this.seq;
	}
	,getLineNo: function() {
		return this.line;
	}
};
var FastaAlignmentParser = function(fileContent,allChecks,allSort,fileNr) {
	this.fastaContent = [];
	this.seqLength = -1;
	if(fileContent == null) {
		return;
	}
	var end = fileContent.length;
	while(true) {
		var tmp;
		if(end > 0) {
			var cCode = HxOverrides.cca(fileContent,end - 1);
			var result = false;
			var _g = 0;
			var _g1 = [9,10,11,12,13,32,133,160,5760,8192,8192,8193,8194,8195,8196,8197,8198,8199,8200,8201,8202,8232,8233,8239,8287,12288,6158,8203,8204,8205,8288,65279];
			while(_g < _g1.length) {
				var ele = _g1[_g];
				++_g;
				if(ele == cCode) {
					result = true;
					break;
				}
			}
			tmp = result;
		} else {
			tmp = false;
		}
		if(!tmp) {
			break;
		}
		--end;
	}
	var s = fileContent.substring(0,end);
	var begin = 0;
	var sLen = s.length;
	while(true) {
		var tmp1;
		if(begin < sLen) {
			var cCode1 = HxOverrides.cca(s,begin);
			var result1 = false;
			var _g2 = 0;
			var _g11 = [9,10,11,12,13,32,133,160,5760,8192,8192,8193,8194,8195,8196,8197,8198,8199,8200,8201,8202,8232,8233,8239,8287,12288,6158,8203,8204,8205,8288,65279];
			while(_g2 < _g11.length) {
				var ele1 = _g11[_g2];
				++_g2;
				if(ele1 == cCode1) {
					result1 = true;
					break;
				}
			}
			tmp1 = result1;
		} else {
			tmp1 = false;
		}
		if(!tmp1) {
			break;
		}
		++begin;
	}
	if(HxOverrides.substr(s,begin,null) == "") {
		SeqPhase1Result.instance().addErr("Empty file!",fileNr);
		return;
	}
	if(HxOverrides.substr(fileContent,0,">".length) != ">" && HxOverrides.substr(fileContent,0,";".length) != ";") {
		SeqPhase1Result.instance().addErr("File does not seem to be a fasta file!",fileNr);
		return;
	}
	var lines = fileContent.split("\n");
	if(lines.length == 0) {
		SeqPhase1Result.instance().addErr("Not a fasta but an empty file!",fileNr);
		return;
	} else if(lines.length == 1) {
		SeqPhase1Result.instance().addErr("Only 1 line detected! Please check data format (opening the alignment in MEGA (http://www.megasoftware.net/) and exporting it as FASTA again may solve the problem; alternatively, there may be a problem with end-of-line characters - see http://en.wikipedia.org/wiki/Newline for details!",fileNr);
		return;
	}
	var entryMap = new haxe_ds_StringMap();
	var current = null;
	var lineNo = 0;
	var underscoreWarningOutputted = false;
	var _g3 = 0;
	while(_g3 < lines.length) {
		var line = lines[_g3];
		++_g3;
		++lineNo;
		var end1 = line.length;
		while(true) {
			var line1;
			if(end1 > 0) {
				var cCode2 = HxOverrides.cca(line,end1 - 1);
				var result2 = false;
				var _g4 = 0;
				var _g12 = [9,10,11,12,13,32,133,160,5760,8192,8192,8193,8194,8195,8196,8197,8198,8199,8200,8201,8202,8232,8233,8239,8287,12288,6158,8203,8204,8205,8288,65279];
				while(_g4 < _g12.length) {
					var ele2 = _g12[_g4];
					++_g4;
					if(ele2 == cCode2) {
						result2 = true;
						break;
					}
				}
				line1 = result2;
			} else {
				line1 = false;
			}
			if(!line1) {
				break;
			}
			--end1;
		}
		var s1 = line.substring(0,end1);
		var begin1 = 0;
		var sLen1 = s1.length;
		while(true) {
			var line2;
			if(begin1 < sLen1) {
				var cCode3 = HxOverrides.cca(s1,begin1);
				var result3 = false;
				var _g5 = 0;
				var _g13 = [9,10,11,12,13,32,133,160,5760,8192,8192,8193,8194,8195,8196,8197,8198,8199,8200,8201,8202,8232,8233,8239,8287,12288,6158,8203,8204,8205,8288,65279];
				while(_g5 < _g13.length) {
					var ele3 = _g13[_g5];
					++_g5;
					if(ele3 == cCode3) {
						result3 = true;
						break;
					}
				}
				line2 = result3;
			} else {
				line2 = false;
			}
			if(!line2) {
				break;
			}
			++begin1;
		}
		line = HxOverrides.substr(s1,begin1,null);
		if(HxOverrides.substr(line,0,";".length) == ";") {
			continue;
		} else if(HxOverrides.substr(line,0,">".length) == ">") {
			var s2 = HxOverrides.substr(line,1,null);
			var end2 = s2.length;
			while(true) {
				var tmp2;
				if(end2 > 0) {
					var cCode4 = HxOverrides.cca(s2,end2 - 1);
					var result4 = false;
					var _g6 = 0;
					var _g14 = [9,10,11,12,13,32,133,160,5760,8192,8192,8193,8194,8195,8196,8197,8198,8199,8200,8201,8202,8232,8233,8239,8287,12288,6158,8203,8204,8205,8288,65279];
					while(_g6 < _g14.length) {
						var ele4 = _g14[_g6];
						++_g6;
						if(ele4 == cCode4) {
							result4 = true;
							break;
						}
					}
					tmp2 = result4;
				} else {
					tmp2 = false;
				}
				if(!tmp2) {
					break;
				}
				--end2;
			}
			var s3 = s2.substring(0,end2);
			var begin2 = 0;
			var sLen2 = s3.length;
			while(true) {
				var tmp3;
				if(begin2 < sLen2) {
					var cCode5 = HxOverrides.cca(s3,begin2);
					var result5 = false;
					var _g7 = 0;
					var _g15 = [9,10,11,12,13,32,133,160,5760,8192,8192,8193,8194,8195,8196,8197,8198,8199,8200,8201,8202,8232,8233,8239,8287,12288,6158,8203,8204,8205,8288,65279];
					while(_g7 < _g15.length) {
						var ele5 = _g15[_g7];
						++_g7;
						if(ele5 == cCode5) {
							result5 = true;
							break;
						}
					}
					tmp3 = result5;
				} else {
					tmp3 = false;
				}
				if(!tmp3) {
					break;
				}
				++begin2;
			}
			var indName = HxOverrides.substr(s3,begin2,null);
			var indNameCor = StringTools.replace(indName," ","_");
			if(indName != indNameCor) {
				if(!underscoreWarningOutputted) {
					SeqPhase1Result.instance().addWrn("Warning: PHASE does not accept spaces in individual names. These spaces got replaced by underscore characters.",fileNr);
					underscoreWarningOutputted = true;
				}
				indName = indNameCor;
			}
			if(__map_reserved[indName] != null ? entryMap.existsReserved(indName) : entryMap.h.hasOwnProperty(indName)) {
				SeqPhase1Result.instance().addErr("Repeat of name " + indName + " encountered in alignment (line " + lineNo + ", line " + (__map_reserved[indName] != null ? entryMap.getReserved(indName) : entryMap.h[indName]).getLineNo() + ")",fileNr);
			}
			current = new Entry(lineNo,indName);
			if(__map_reserved[indName] != null) {
				entryMap.setReserved(indName,current);
			} else {
				entryMap.h[indName] = current;
			}
			if(indName.length == 0) {
				SeqPhase1Result.instance().addErr("Missing sequence name, line " + lineNo,fileNr);
			}
		} else {
			var _g21 = 0;
			var _g16 = line.length;
			while(_g21 < _g16) {
				var i = _g21++;
				var $char = line.charAt(i).toUpperCase();
				var _this = FastaAlignmentParser.authorizedCharacters;
				if(!(__map_reserved[$char] != null ? _this.existsReserved($char) : _this.h.hasOwnProperty($char))) {
					SeqPhase1Result.instance().addErr("Unknown character state " + $char + " in " + current.getName() + ", line " + lineNo,fileNr);
				} else {
					var tmp4;
					if(allChecks) {
						var _this1 = FastaAlignmentParser.authorizedCharacters;
						tmp4 = (__map_reserved[$char] != null ? _this1.getReserved($char) : _this1.h[$char]) == false;
					} else {
						tmp4 = false;
					}
					if(tmp4) {
						SeqPhase1Result.instance().addErr("Unallowed state " + $char + " in " + current.getName() + ", line " + lineNo,fileNr);
					}
				}
			}
			line = line.split("?").join("N");
			current.addToSeq(line.toUpperCase());
		}
	}
	if(current == null) {
		SeqPhase1Result.instance().addErr("Corrupted Fasta File",fileNr);
		return;
	}
	if(current.getSeq() == "") {
		SeqPhase1Result.instance().addErr("Empty sequence " + current.getName() + ", line " + current.getLineNo(),fileNr);
		return;
	}
	this.seqLength = current.getSeq().length;
	var key = entryMap.keys();
	while(key.hasNext()) {
		var key1 = key.next();
		var val = __map_reserved[key1] != null ? entryMap.getReserved(key1) : entryMap.h[key1];
		this.fastaContent.push(val);
		if(val.getSeq().length != current.getSeq().length) {
			SeqPhase1Result.instance().addErr("Not all sequences in this file have equal lengths. E.g. sequence " + val.getName() + " (line " + val.getLineNo() + ") is of length " + val.getSeq().length + " while sequence " + current.getName() + " (line " + current.getLineNo() + ") is of length " + current.getSeq().length,fileNr);
			return;
		}
		if(HxOverrides.substr(val.getSeq(),0,"-".length) == "-") {
			SeqPhase1Result.instance().addWrn("Sequence " + val.getName() + " (line " + val.getLineNo() + ") starts with '-'. Is it a real indel or did you mean 'N' or '?' (missing data)?",fileNr);
		}
		if(val.getSeq().charAt(val.getSeq().length - 1) == "-") {
			SeqPhase1Result.instance().addWrn("Sequence " + val.getName() + " (line " + val.getLineNo() + ") ends with '-'. Is it a real indel or did you mean 'N' or '?' (missing data)?",fileNr);
		}
	}
	this.fastaContent.sort(function(e1,e2) {
		if(allSort) {
			var nameE1 = e1.getName();
			var nameE2 = e1.getName();
			var aNameE1 = nameE1.substring(0,nameE1.length - 1);
			var aNameE2 = nameE2.substring(0,nameE2.length - 1);
			if(aNameE1 < aNameE2) {
				return -1;
			}
			if(aNameE1 > aNameE2) {
				return 1;
			}
			var lNameE1 = nameE1.charAt(nameE1.length - 1);
			var lNameE2 = nameE2.charAt(nameE2.length - 1);
			if(lNameE1 < lNameE2) {
				return -1;
			}
			if(lNameE1 > lNameE2) {
				return 1;
			}
			return 0;
		} else {
			if(e1.getName() < e2.getName()) {
				return -1;
			}
			if(e1.getName() > e2.getName()) {
				return 1;
			}
			return 0;
		}
	});
	if(allChecks) {
		if(this.fastaContent.length % 2 != 0) {
			SeqPhase1Result.instance().addErr("Uneven number of sequences in alignment: please check data.",fileNr);
		}
		var lastName = null;
		var _g8 = 0;
		var _g17 = this.fastaContent;
		while(_g8 < _g17.length) {
			var entry = _g17[_g8];
			++_g8;
			if(lastName == null) {
				lastName = entry.getName();
				lastName = lastName.substring(0,lastName.length - 1);
			} else {
				var curName = entry.getName();
				curName = curName.substring(0,curName.length - 1);
				if(lastName != curName) {
					SeqPhase1Result.instance().addErr("Only one haplotype sequence found for individual " + entry.getName(),fileNr);
				} else {
					lastName = null;
				}
			}
		}
	}
};
FastaAlignmentParser.__name__ = true;
FastaAlignmentParser.startsWith = function(t,s) {
	return HxOverrides.substr(t,0,s.length) == s;
};
FastaAlignmentParser.isWhitespace = function(s,pos) {
	var cCode = HxOverrides.cca(s,pos);
	var result = false;
	var _g = 0;
	var _g1 = [9,10,11,12,13,32,133,160,5760,8192,8192,8193,8194,8195,8196,8197,8198,8199,8200,8201,8202,8232,8233,8239,8287,12288,6158,8203,8204,8205,8288,65279];
	while(_g < _g1.length) {
		var ele = _g1[_g];
		++_g;
		if(ele == cCode) {
			result = true;
			break;
		}
	}
	return result;
};
FastaAlignmentParser.stripStringBegin = function(s) {
	var begin = 0;
	var sLen = s.length;
	while(true) {
		var tmp;
		if(begin < sLen) {
			var cCode = HxOverrides.cca(s,begin);
			var result = false;
			var _g = 0;
			var _g1 = [9,10,11,12,13,32,133,160,5760,8192,8192,8193,8194,8195,8196,8197,8198,8199,8200,8201,8202,8232,8233,8239,8287,12288,6158,8203,8204,8205,8288,65279];
			while(_g < _g1.length) {
				var ele = _g1[_g];
				++_g;
				if(ele == cCode) {
					result = true;
					break;
				}
			}
			tmp = result;
		} else {
			tmp = false;
		}
		if(!tmp) {
			break;
		}
		++begin;
	}
	return HxOverrides.substr(s,begin,null);
};
FastaAlignmentParser.stripStringEnd = function(s) {
	var end = s.length;
	while(true) {
		var tmp;
		if(end > 0) {
			var cCode = HxOverrides.cca(s,end - 1);
			var result = false;
			var _g = 0;
			var _g1 = [9,10,11,12,13,32,133,160,5760,8192,8192,8193,8194,8195,8196,8197,8198,8199,8200,8201,8202,8232,8233,8239,8287,12288,6158,8203,8204,8205,8288,65279];
			while(_g < _g1.length) {
				var ele = _g1[_g];
				++_g;
				if(ele == cCode) {
					result = true;
					break;
				}
			}
			tmp = result;
		} else {
			tmp = false;
		}
		if(!tmp) {
			break;
		}
		--end;
	}
	return s.substring(0,end);
};
FastaAlignmentParser.stripString = function(s) {
	var end = s.length;
	while(true) {
		var tmp;
		if(end > 0) {
			var cCode = HxOverrides.cca(s,end - 1);
			var result = false;
			var _g = 0;
			var _g1 = [9,10,11,12,13,32,133,160,5760,8192,8192,8193,8194,8195,8196,8197,8198,8199,8200,8201,8202,8232,8233,8239,8287,12288,6158,8203,8204,8205,8288,65279];
			while(_g < _g1.length) {
				var ele = _g1[_g];
				++_g;
				if(ele == cCode) {
					result = true;
					break;
				}
			}
			tmp = result;
		} else {
			tmp = false;
		}
		if(!tmp) {
			break;
		}
		--end;
	}
	var s1 = s.substring(0,end);
	var begin = 0;
	var sLen = s1.length;
	while(true) {
		var tmp1;
		if(begin < sLen) {
			var cCode1 = HxOverrides.cca(s1,begin);
			var result1 = false;
			var _g2 = 0;
			var _g11 = [9,10,11,12,13,32,133,160,5760,8192,8192,8193,8194,8195,8196,8197,8198,8199,8200,8201,8202,8232,8233,8239,8287,12288,6158,8203,8204,8205,8288,65279];
			while(_g2 < _g11.length) {
				var ele1 = _g11[_g2];
				++_g2;
				if(ele1 == cCode1) {
					result1 = true;
					break;
				}
			}
			tmp1 = result1;
		} else {
			tmp1 = false;
		}
		if(!tmp1) {
			break;
		}
		++begin;
	}
	return HxOverrides.substr(s1,begin,null);
};
FastaAlignmentParser.prototype = {
	getSeqLength: function() {
		return this.seqLength;
	}
	,getSequences: function() {
		return this.fastaContent;
	}
};
var HxOverrides = function() { };
HxOverrides.__name__ = true;
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) {
		return undefined;
	}
	return x;
};
HxOverrides.substr = function(s,pos,len) {
	if(len == null) {
		len = s.length;
	} else if(len < 0) {
		if(pos == 0) {
			len = s.length + len;
		} else {
			return "";
		}
	}
	return s.substr(pos,len);
};
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
};
var List = function() {
	this.length = 0;
};
List.__name__ = true;
List.prototype = {
	add: function(item) {
		var x = new _$List_ListNode(item,null);
		if(this.h == null) {
			this.h = x;
		} else {
			this.q.next = x;
		}
		this.q = x;
		this.length++;
	}
	,join: function(sep) {
		var s_b = "";
		var first = true;
		var l = this.h;
		while(l != null) {
			if(first) {
				first = false;
			} else {
				s_b += sep == null ? "null" : "" + sep;
			}
			s_b += Std.string(l.item);
			l = l.next;
		}
		return s_b;
	}
};
var _$List_ListNode = function(item,next) {
	this.item = item;
	this.next = next;
};
_$List_ListNode.__name__ = true;
var _$List_ListIterator = function(head) {
	this.head = head;
};
_$List_ListIterator.__name__ = true;
_$List_ListIterator.prototype = {
	hasNext: function() {
		return this.head != null;
	}
	,next: function() {
		var val = this.head.item;
		this.head = this.head.next;
		return val;
	}
};
Math.__name__ = true;
var SeqPhase1 = function() { };
SeqPhase1.__name__ = true;
SeqPhase1.doIt = function(align1,align2,align3) {
	SeqPhase1Result.instance().clear();
	var al1 = new FastaAlignmentParser(align1,false,false,1);
	var al2 = new FastaAlignmentParser(align2,true,true,2);
	var al3 = new FastaAlignmentParser(align3,true,false,3);
	var expectedLength = al1.getSeqLength() > al2.getSeqLength() ? al1.getSeqLength() : al2.getSeqLength();
	if(expectedLength > al3.getSeqLength()) {
		expectedLength = expectedLength;
	} else {
		expectedLength = al3.getSeqLength();
	}
	var diffLength = false;
	if(al1.getSeqLength() != -1 && al1.getSeqLength() != expectedLength) {
		diffLength = true;
	}
	if(al2.getSeqLength() != -1 && al2.getSeqLength() != expectedLength) {
		diffLength = true;
	}
	if(al3.getSeqLength() != -1 && al3.getSeqLength() != expectedLength) {
		diffLength = true;
	}
	if(diffLength) {
		SeqPhase1Result.instance().addGeneralError("Not all input sequences have equal lengths, please check whether this is expected.");
	} else if(expectedLength == -1 || expectedLength == 0) {
		SeqPhase1Result.instance().addGeneralError("It seems that all given sequences are empty ...");
	}
	if(SeqPhase1Result.instance().hasErrors()) {
		return SeqPhase1Result.instance();
	}
	var al1a = new List();
	var al1b = new List();
	var _g = 0;
	var _g1 = al1.getSequences();
	while(_g < _g1.length) {
		var entry = _g1[_g];
		++_g;
		var seq1a = new List();
		var seq1b = new List();
		var _g3 = 0;
		var _g2 = entry.getSeq().length;
		while(_g3 < _g2) {
			var i = _g3++;
			var c = entry.getSeq().charAt(i);
			var _this = SeqPhase1.map1;
			if(__map_reserved[c] != null ? _this.existsReserved(c) : _this.h.hasOwnProperty(c)) {
				var _this1 = SeqPhase1.map1;
				seq1a.add(__map_reserved[c] != null ? _this1.getReserved(c) : _this1.h[c]);
				var _this2 = SeqPhase1.map2;
				seq1b.add(__map_reserved[c] != null ? _this2.getReserved(c) : _this2.h[c]);
			} else {
				seq1a.add(c);
				seq1b.add(c);
			}
		}
		al1a.add(new Entry(entry.getLineNo(),entry.getName(),seq1a.join("")));
		al1b.add(new Entry(entry.getLineNo(),entry.getName(),seq1b.join("")));
	}
	var varpos = new List();
	var multipos = new List();
	var multiposMap_h = { };
	var constFileContent = new List();
	var _g11 = 0;
	var _g4 = expectedLength;
	while(_g11 < _g4) {
		var i1 = _g11++;
		var m = new haxe_ds_StringMap();
		var _g2_head = al1a.h;
		while(_g2_head != null) {
			var val = _g2_head.item;
			_g2_head = _g2_head.next;
			var entry1 = val;
			var key = entry1.getSeq().charAt(i1);
			if(__map_reserved[key] != null) {
				m.setReserved(key,false);
			} else {
				m.h[key] = false;
			}
		}
		var _g2_head1 = al1b.h;
		while(_g2_head1 != null) {
			var val1 = _g2_head1.item;
			_g2_head1 = _g2_head1.next;
			var entry2 = val1;
			var key1 = entry2.getSeq().charAt(i1);
			if(__map_reserved[key1] != null) {
				m.setReserved(key1,false);
			} else {
				m.h[key1] = false;
			}
		}
		var _g21 = 0;
		var _g31 = al2.getSequences();
		while(_g21 < _g31.length) {
			var entry3 = _g31[_g21];
			++_g21;
			var key2 = entry3.getSeq().charAt(i1);
			if(__map_reserved[key2] != null) {
				m.setReserved(key2,false);
			} else {
				m.h[key2] = false;
			}
		}
		var _g22 = 0;
		var _g32 = al3.getSequences();
		while(_g22 < _g32.length) {
			var entry4 = _g32[_g22];
			++_g22;
			var key3 = entry4.getSeq().charAt(i1);
			if(__map_reserved[key3] != null) {
				m.setReserved(key3,false);
			} else {
				m.h[key3] = false;
			}
		}
		var mapLen = 0;
		var mapLenWithoutNs = 0;
		var lastKey;
		var key4 = m.keys();
		while(key4.hasNext()) {
			var key5 = key4.next();
			lastKey = key5;
			++mapLen;
			if(key5 != "N") {
				++mapLenWithoutNs;
			}
		}
		if(mapLen == 0) {
			SeqPhase1Result.instance().addGeneralError("Bug detected: There seems to be a bug in this implementation of SeqPHASE. Please contact the author so that they can fix this bug.");
			constFileContent.add("X");
		} else if(mapLen == 1) {
			if(lastKey == "N") {
				SeqPhase1Result.instance().addGeneralWarn("Found only N/? s at position " + (i1 + 1) + ".");
			} else if(lastKey == "-") {
				SeqPhase1Result.instance().addGeneralWarn("Found only -'s at position " + (i1 + 1) + ". This may indicate an alignment problem. Consider to recheck your input data!");
			}
			constFileContent.add(lastKey);
		} else {
			constFileContent.add(".");
			varpos.add(i1);
			if(mapLenWithoutNs > 2) {
				multipos.add(i1);
				multiposMap_h[i1] = true;
			} else {
				multiposMap_h[i1] = false;
			}
		}
	}
	if(varpos.length == 0) {
		SeqPhase1Result.instance().addGeneralError("Not a single variable position detected in dataset! Please check data.");
	} else {
		SeqPhase1Result.instance().addNote("There are " + varpos.length + " variable positions in your dataset, including " + multipos.length + " position(s) with more than two different states.");
	}
	SeqPhase1Result.instance().setConstFile(constFileContent.join(""));
	var lines = new List();
	lines.add("" + (al1a.length + al2.getSequences().length / 2 + al3.getSequences().length / 2 | 0));
	lines.add("" + varpos.length);
	var l1 = new List();
	var l2 = new List();
	var _g_head = varpos.h;
	while(_g_head != null) {
		var val2 = _g_head.item;
		_g_head = _g_head.next;
		var pos = val2;
		l1.add("" + (pos + 1));
		if(multiposMap_h[pos]) {
			l2.add("M");
		} else {
			l2.add("S");
		}
	}
	lines.add("P " + l1.join(" "));
	lines.add(l2.join(" ") + " ");
	var it1 = new _$List_ListIterator(al1a.h);
	var it2 = new _$List_ListIterator(al1b.h);
	while(it1.hasNext()) {
		var e1 = it1.next();
		var e2 = it2.next();
		lines.add(e1.getName());
		var line1 = new List();
		var line2 = new List();
		var _g_head1 = varpos.h;
		while(_g_head1 != null) {
			var val3 = _g_head1.item;
			_g_head1 = _g_head1.next;
			var i2 = val3;
			var $char = e1.getSeq().charAt(i2);
			if($char == "N" && !multiposMap_h.hasOwnProperty(i2)) {
				line1.add("-1");
			} else {
				var _this3 = SeqPhase1.code;
				line1.add(__map_reserved[$char] != null ? _this3.getReserved($char) : _this3.h[$char]);
			}
		}
		var _g_head2 = varpos.h;
		while(_g_head2 != null) {
			var val4 = _g_head2.item;
			_g_head2 = _g_head2.next;
			var i3 = val4;
			var char1 = e2.getSeq().charAt(i3);
			if(char1 == "N" && !multiposMap_h.hasOwnProperty(i3)) {
				line2.add("-1");
			} else {
				var _this4 = SeqPhase1.code;
				line2.add(__map_reserved[char1] != null ? _this4.getReserved(char1) : _this4.h[char1]);
			}
		}
		lines.add(line1.join(" ") + " ");
		lines.add(line2.join(" ") + " ");
	}
	var isOdd = false;
	var _g5 = 0;
	var _g12 = al2.getSequences();
	while(_g5 < _g12.length) {
		var entry5 = _g12[_g5];
		++_g5;
		isOdd = !isOdd;
		if(isOdd) {
			var name = entry5.getName();
			lines.add(HxOverrides.substr(name,0,name.length - 1));
		}
		var line = new List();
		var _g2_head2 = varpos.h;
		while(_g2_head2 != null) {
			var val5 = _g2_head2.item;
			_g2_head2 = _g2_head2.next;
			var i4 = val5;
			var char2 = entry5.getSeq().charAt(i4);
			if(char2 == "N" && !multiposMap_h.hasOwnProperty(i4)) {
				line.add("-1");
			} else {
				var _this5 = SeqPhase1.code;
				line.add(__map_reserved[char2] != null ? _this5.getReserved(char2) : _this5.h[char2]);
			}
		}
		lines.add(line.join(" ") + " ");
	}
	isOdd = false;
	var _g6 = 0;
	var _g13 = al3.getSequences();
	while(_g6 < _g13.length) {
		var entry6 = _g13[_g6];
		++_g6;
		isOdd = !isOdd;
		if(isOdd) {
			var name1 = entry6.getName();
			lines.add(HxOverrides.substr(name1,0,name1.length - 1));
		}
		var line3 = new List();
		var _g2_head3 = varpos.h;
		while(_g2_head3 != null) {
			var val6 = _g2_head3.item;
			_g2_head3 = _g2_head3.next;
			var i5 = val6;
			var char3 = entry6.getSeq().charAt(i5);
			if(char3 == "N" && !multiposMap_h.hasOwnProperty(i5)) {
				line3.add("-1");
			} else {
				var _this6 = SeqPhase1.code;
				line3.add(__map_reserved[char3] != null ? _this6.getReserved(char3) : _this6.h[char3]);
			}
		}
		lines.add(line3.join(" ") + " ");
	}
	lines.add("");
	SeqPhase1Result.instance().setInpFile(lines.join("\n"));
	var knownLines = new List();
	var i6 = varpos.length;
	var result = new List();
	var _g14 = 0;
	var _g7 = i6;
	while(_g14 < _g7) {
		var nnn = _g14++;
		result.add("*");
	}
	var nStr = result.join("");
	var i7 = varpos.length;
	var result1 = new List();
	var _g15 = 0;
	var _g8 = i7;
	while(_g15 < _g8) {
		var nnn1 = _g15++;
		result1.add("0");
	}
	var oStr = result1.join("");
	var _g16 = 0;
	var _g9 = al1.getSequences().length;
	while(_g16 < _g9) {
		var i8 = _g16++;
		knownLines.add(nStr);
	}
	var lll1 = al2.getSequences().length / 2 | 0;
	var _g17 = 0;
	var _g10 = lll1;
	while(_g17 < _g10) {
		var i9 = _g17++;
		knownLines.add(nStr);
	}
	var lll2 = al3.getSequences().length / 2 | 0;
	var _g18 = 0;
	var _g19 = lll2;
	while(_g18 < _g19) {
		var i10 = _g18++;
		knownLines.add(oStr);
	}
	SeqPhase1Result.instance().setKnownFile(knownLines.join("\n"));
	if(al3.getSequences().length == 0) {
		if(multipos.length == 0) {
			SeqPhase1Result.instance().setSuggestedPhaseCommand("PHASE seqphase.inp seqphase.out");
		} else {
			SeqPhase1Result.instance().setSuggestedPhaseCommand("PHASE -d1 seqphase.inp seqphase.out");
		}
	} else if(multipos.length == 0) {
		SeqPhase1Result.instance().setSuggestedPhaseCommand("PHASE -kseqphase.known seqphase.inp seqphase.out");
	} else {
		SeqPhase1Result.instance().setSuggestedPhaseCommand("PHASE -d1 -kseqphase.known seqphase.inp seqphase.out");
	}
	return SeqPhase1Result.instance();
};
SeqPhase1.makeStr = function(c,i) {
	var result = new List();
	var _g1 = 0;
	var _g = i;
	while(_g1 < _g) {
		var nnn = _g1++;
		result.add(c);
	}
	return result.join("");
};
SeqPhase1.main = function() {
};
var SeqPhase1Result = function() {
	this.clear();
};
SeqPhase1Result.__name__ = true;
SeqPhase1Result.instance = function() {
	if(SeqPhase1Result.inst == null) {
		SeqPhase1Result.inst = new SeqPhase1Result();
	}
	return SeqPhase1Result.inst;
};
SeqPhase1Result.prototype = {
	clear: function() {
		this.errorsAlign1 = new List();
		this.warningsAlign1 = new List();
		this.errorsAlign2 = new List();
		this.warningsAlign2 = new List();
		this.errorsAlign3 = new List();
		this.warningsAlign3 = new List();
		this.errorsGeneral = new List();
		this.warningsGeneral = new List();
		this.notes = new List();
		this.suggestedPhaseCommand = null;
		this.varPos = null;
		this.nbVarPos = null;
		this.inpFile = null;
		this.knownFile = null;
		this.constFile = null;
	}
	,addErr: function(err,nr) {
		if(nr == 1) {
			this.addAlign1Error(err);
		} else if(nr == 2) {
			this.addAlign2Error(err);
		} else if(nr == 3) {
			this.addAlign3Error(err);
		} else {
			throw new js__$Boot_HaxeError("Illegal nr " + nr);
		}
	}
	,addWrn: function(wrn,nr) {
		if(nr == 1) {
			this.addAlign1Warn(wrn);
		} else if(nr == 2) {
			this.addAlign2Warn(wrn);
		} else if(nr == 3) {
			this.addAlign3Warn(wrn);
		} else {
			throw new js__$Boot_HaxeError("Illegal nr " + nr);
		}
	}
	,addAlign1Error: function(err) {
		this.errorsAlign1.add(err);
	}
	,hasAlign1Errors: function() {
		return this.errorsAlign1.length != 0;
	}
	,getAlign1Errors: function() {
		var length = this.errorsAlign1.length;
		var this1 = new Array(length);
		var result = this1;
		var i = 0;
		var _g_head = this.errorsAlign1.h;
		while(_g_head != null) {
			var val = _g_head.item;
			_g_head = _g_head.next;
			var item = val;
			result[i++] = item;
		}
		return result;
	}
	,addAlign1Warn: function(wrn) {
		this.warningsAlign1.add(wrn);
	}
	,hasAlign1Warn: function() {
		return this.warningsAlign1.length != 0;
	}
	,getAlign1Warn: function() {
		var length = this.warningsAlign1.length;
		var this1 = new Array(length);
		var result = this1;
		var i = 0;
		var _g_head = this.warningsAlign1.h;
		while(_g_head != null) {
			var val = _g_head.item;
			_g_head = _g_head.next;
			var item = val;
			result[i++] = item;
		}
		return result;
	}
	,addAlign2Error: function(err) {
		this.errorsAlign2.add(err);
	}
	,hasAlign2Errors: function() {
		return this.errorsAlign2.length != 0;
	}
	,getAlign2Errors: function() {
		var length = this.errorsAlign2.length;
		var this1 = new Array(length);
		var result = this1;
		var i = 0;
		var _g_head = this.errorsAlign2.h;
		while(_g_head != null) {
			var val = _g_head.item;
			_g_head = _g_head.next;
			var item = val;
			result[i++] = item;
		}
		return result;
	}
	,addAlign2Warn: function(wrn) {
		this.warningsAlign2.add(wrn);
	}
	,hasAlign2Warn: function() {
		return this.warningsAlign2.length != 0;
	}
	,getAlign2Warn: function() {
		var length = this.warningsAlign2.length;
		var this1 = new Array(length);
		var result = this1;
		var i = 0;
		var _g_head = this.warningsAlign2.h;
		while(_g_head != null) {
			var val = _g_head.item;
			_g_head = _g_head.next;
			var item = val;
			result[i++] = item;
		}
		return result;
	}
	,addAlign3Error: function(err) {
		this.errorsAlign3.add(err);
	}
	,hasAlign3Errors: function() {
		return this.errorsAlign3.length != 0;
	}
	,getAlign3Errors: function() {
		var length = this.errorsAlign3.length;
		var this1 = new Array(length);
		var result = this1;
		var i = 0;
		var _g_head = this.errorsAlign3.h;
		while(_g_head != null) {
			var val = _g_head.item;
			_g_head = _g_head.next;
			var item = val;
			result[i++] = item;
		}
		return result;
	}
	,addAlign3Warn: function(wrn) {
		this.warningsAlign3.add(wrn);
	}
	,hasAlign3Warn: function() {
		return this.warningsAlign3.length != 0;
	}
	,getAlign3Warn: function() {
		var length = this.warningsAlign3.length;
		var this1 = new Array(length);
		var result = this1;
		var i = 0;
		var _g_head = this.warningsAlign3.h;
		while(_g_head != null) {
			var val = _g_head.item;
			_g_head = _g_head.next;
			var item = val;
			result[i++] = item;
		}
		return result;
	}
	,addGeneralError: function(err) {
		this.errorsGeneral.add(err);
	}
	,hasGeneralErrors: function() {
		return this.errorsGeneral.length != 0;
	}
	,getGeneralErrors: function() {
		var length = this.errorsGeneral.length;
		var this1 = new Array(length);
		var result = this1;
		var i = 0;
		var _g_head = this.errorsGeneral.h;
		while(_g_head != null) {
			var val = _g_head.item;
			_g_head = _g_head.next;
			var item = val;
			result[i++] = item;
		}
		return result;
	}
	,addGeneralWarn: function(wrn) {
		this.warningsGeneral.add(wrn);
	}
	,hasGeneralWarn: function() {
		return this.warningsGeneral.length != 0;
	}
	,getGeneralWarn: function() {
		var length = this.warningsGeneral.length;
		var this1 = new Array(length);
		var result = this1;
		var i = 0;
		var _g_head = this.warningsGeneral.h;
		while(_g_head != null) {
			var val = _g_head.item;
			_g_head = _g_head.next;
			var item = val;
			result[i++] = item;
		}
		return result;
	}
	,hasErrors: function() {
		if(!(this.errorsAlign1.length > 0 || this.errorsAlign2.length > 0 || this.errorsAlign3.length > 0)) {
			return this.errorsGeneral.length > 0;
		} else {
			return true;
		}
	}
	,addNote: function(note) {
		this.notes.add(note);
	}
	,hasNotes: function() {
		return this.notes.length != 0;
	}
	,getNotes: function() {
		var length = this.notes.length;
		var this1 = new Array(length);
		var result = this1;
		var i = 0;
		var _g_head = this.notes.h;
		while(_g_head != null) {
			var val = _g_head.item;
			_g_head = _g_head.next;
			var item = val;
			result[i++] = item;
		}
		return result;
	}
	,setSuggestedPhaseCommand: function(ph) {
		this.suggestedPhaseCommand = ph;
	}
	,hasSuggestedCommand: function() {
		return this.suggestedPhaseCommand != null;
	}
	,getSuggestedPhaseCommand: function() {
		return this.suggestedPhaseCommand;
	}
	,setNrVarPos: function(nr) {
		this.varPos = nr;
	}
	,getNrVarPos: function() {
		return this.varPos;
	}
	,setNrNbVarPos: function(nr) {
		this.nbVarPos = nr;
	}
	,getNrNbVarPos: function() {
		return this.nbVarPos;
	}
	,setInpFile: function(content) {
		this.inpFile = content;
	}
	,hasInpFile: function() {
		return this.inpFile != null;
	}
	,getInpFile: function() {
		return this.inpFile;
	}
	,setKnownFile: function(content) {
		this.knownFile = content;
	}
	,hasKnownFile: function() {
		return this.knownFile != null;
	}
	,getKnownFile: function() {
		return this.knownFile;
	}
	,setConstFile: function(content) {
		this.constFile = content;
	}
	,hasConstFile: function() {
		return this.constFile != null;
	}
	,getConstFile: function() {
		return this.constFile;
	}
};
var Std = function() { };
Std.__name__ = true;
Std.string = function(s) {
	return js_Boot.__string_rec(s,"");
};
var StringTools = function() { };
StringTools.__name__ = true;
StringTools.replace = function(s,sub,by) {
	return s.split(sub).join(by);
};
var haxe_IMap = function() { };
haxe_IMap.__name__ = true;
var haxe_ds_StringMap = function() {
	this.h = { };
};
haxe_ds_StringMap.__name__ = true;
haxe_ds_StringMap.__interfaces__ = [haxe_IMap];
haxe_ds_StringMap.prototype = {
	setReserved: function(key,value) {
		if(this.rh == null) {
			this.rh = { };
		}
		this.rh["$" + key] = value;
	}
	,getReserved: function(key) {
		if(this.rh == null) {
			return null;
		} else {
			return this.rh["$" + key];
		}
	}
	,existsReserved: function(key) {
		if(this.rh == null) {
			return false;
		}
		return this.rh.hasOwnProperty("$" + key);
	}
	,keys: function() {
		return HxOverrides.iter(this.arrayKeys());
	}
	,arrayKeys: function() {
		var out = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) {
			out.push(key);
		}
		}
		if(this.rh != null) {
			for( var key in this.rh ) {
			if(key.charCodeAt(0) == 36) {
				out.push(key.substr(1));
			}
			}
		}
		return out;
	}
};
var js__$Boot_HaxeError = function(val) {
	Error.call(this);
	this.val = val;
	this.message = String(val);
	if(Error.captureStackTrace) {
		Error.captureStackTrace(this,js__$Boot_HaxeError);
	}
};
js__$Boot_HaxeError.__name__ = true;
js__$Boot_HaxeError.wrap = function(val) {
	if((val instanceof Error)) {
		return val;
	} else {
		return new js__$Boot_HaxeError(val);
	}
};
js__$Boot_HaxeError.__super__ = Error;
js__$Boot_HaxeError.prototype = $extend(Error.prototype,{
});
var js_Boot = function() { };
js_Boot.__name__ = true;
js_Boot.__string_rec = function(o,s) {
	if(o == null) {
		return "null";
	}
	if(s.length >= 5) {
		return "<...>";
	}
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) {
		t = "object";
	}
	switch(t) {
	case "function":
		return "<function>";
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) {
					return o[0];
				}
				var str = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i = _g1++;
					if(i != 2) {
						str += "," + js_Boot.__string_rec(o[i],s);
					} else {
						str += js_Boot.__string_rec(o[i],s);
					}
				}
				return str + ")";
			}
			var l = o.length;
			var i1;
			var str1 = "[";
			s += "\t";
			var _g11 = 0;
			var _g2 = l;
			while(_g11 < _g2) {
				var i2 = _g11++;
				str1 += (i2 > 0 ? "," : "") + js_Boot.__string_rec(o[i2],s);
			}
			str1 += "]";
			return str1;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
			var s2 = o.toString();
			if(s2 != "[object Object]") {
				return s2;
			}
		}
		var k = null;
		var str2 = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str2.length != 2) {
			str2 += ", \n";
		}
		str2 += s + k + " : " + js_Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str2 += "\n" + s + "}";
		return str2;
	case "string":
		return o;
	default:
		return String(o);
	}
};
String.__name__ = true;
Array.__name__ = true;
var __map_reserved = {};
FastaAlignmentParser.authorizedCharacters = (function($this) {
	var $r;
	var _g = new haxe_ds_StringMap();
	if(__map_reserved["A"] != null) {
		_g.setReserved("A",true);
	} else {
		_g.h["A"] = true;
	}
	if(__map_reserved["T"] != null) {
		_g.setReserved("T",true);
	} else {
		_g.h["T"] = true;
	}
	if(__map_reserved["G"] != null) {
		_g.setReserved("G",true);
	} else {
		_g.h["G"] = true;
	}
	if(__map_reserved["C"] != null) {
		_g.setReserved("C",true);
	} else {
		_g.h["C"] = true;
	}
	if(__map_reserved["N"] != null) {
		_g.setReserved("N",true);
	} else {
		_g.h["N"] = true;
	}
	if(__map_reserved["-"] != null) {
		_g.setReserved("-",true);
	} else {
		_g.h["-"] = true;
	}
	if(__map_reserved["?"] != null) {
		_g.setReserved("?",true);
	} else {
		_g.h["?"] = true;
	}
	if(__map_reserved["R"] != null) {
		_g.setReserved("R",false);
	} else {
		_g.h["R"] = false;
	}
	if(__map_reserved["Y"] != null) {
		_g.setReserved("Y",false);
	} else {
		_g.h["Y"] = false;
	}
	if(__map_reserved["M"] != null) {
		_g.setReserved("M",false);
	} else {
		_g.h["M"] = false;
	}
	if(__map_reserved["K"] != null) {
		_g.setReserved("K",false);
	} else {
		_g.h["K"] = false;
	}
	if(__map_reserved["W"] != null) {
		_g.setReserved("W",false);
	} else {
		_g.h["W"] = false;
	}
	if(__map_reserved["S"] != null) {
		_g.setReserved("S",false);
	} else {
		_g.h["S"] = false;
	}
	$r = _g;
	return $r;
}(this));
SeqPhase1.map1 = (function($this) {
	var $r;
	var _g = new haxe_ds_StringMap();
	if(__map_reserved["W"] != null) {
		_g.setReserved("W","A");
	} else {
		_g.h["W"] = "A";
	}
	if(__map_reserved["S"] != null) {
		_g.setReserved("S","C");
	} else {
		_g.h["S"] = "C";
	}
	if(__map_reserved["K"] != null) {
		_g.setReserved("K","T");
	} else {
		_g.h["K"] = "T";
	}
	if(__map_reserved["M"] != null) {
		_g.setReserved("M","A");
	} else {
		_g.h["M"] = "A";
	}
	if(__map_reserved["Y"] != null) {
		_g.setReserved("Y","C");
	} else {
		_g.h["Y"] = "C";
	}
	if(__map_reserved["R"] != null) {
		_g.setReserved("R","A");
	} else {
		_g.h["R"] = "A";
	}
	$r = _g;
	return $r;
}(this));
SeqPhase1.map2 = (function($this) {
	var $r;
	var _g = new haxe_ds_StringMap();
	if(__map_reserved["W"] != null) {
		_g.setReserved("W","T");
	} else {
		_g.h["W"] = "T";
	}
	if(__map_reserved["S"] != null) {
		_g.setReserved("S","G");
	} else {
		_g.h["S"] = "G";
	}
	if(__map_reserved["K"] != null) {
		_g.setReserved("K","G");
	} else {
		_g.h["K"] = "G";
	}
	if(__map_reserved["M"] != null) {
		_g.setReserved("M","C");
	} else {
		_g.h["M"] = "C";
	}
	if(__map_reserved["Y"] != null) {
		_g.setReserved("Y","T");
	} else {
		_g.h["Y"] = "T";
	}
	if(__map_reserved["R"] != null) {
		_g.setReserved("R","G");
	} else {
		_g.h["R"] = "G";
	}
	$r = _g;
	return $r;
}(this));
SeqPhase1.code = (function($this) {
	var $r;
	var _g = new haxe_ds_StringMap();
	if(__map_reserved["A"] != null) {
		_g.setReserved("A","1");
	} else {
		_g.h["A"] = "1";
	}
	if(__map_reserved["C"] != null) {
		_g.setReserved("C","2");
	} else {
		_g.h["C"] = "2";
	}
	if(__map_reserved["G"] != null) {
		_g.setReserved("G","3");
	} else {
		_g.h["G"] = "3";
	}
	if(__map_reserved["T"] != null) {
		_g.setReserved("T","4");
	} else {
		_g.h["T"] = "4";
	}
	if(__map_reserved["?"] != null) {
		_g.setReserved("?","?");
	} else {
		_g.h["?"] = "?";
	}
	if(__map_reserved["N"] != null) {
		_g.setReserved("N","?");
	} else {
		_g.h["N"] = "?";
	}
	if(__map_reserved["-"] != null) {
		_g.setReserved("-","0");
	} else {
		_g.h["-"] = "0";
	}
	$r = _g;
	return $r;
}(this));
