eval(require('fs').readFileSync('./test_babel.js', 'utf8')); 
var assert = require('assert');

var testComplex_ser = new TestComplex();
testComplex_ser.list1 = [0, 1, 255, 0x7FFFFFFF, 0x7FFFFFFF+1, 0xFFFFFFFE, 0xFFFFFFFF];
testComplex_ser.list2 = [0,1, 15,16, 127,128, 254,255];
testComplex_ser.map1[0] = 10;
testComplex_ser.map1[10] = 100;
testComplex_ser.map2["FooBar"] = [new Entry(), new Entry()];

var ca = testComplex_ser.serialize();

var testComplex_deser = new TestComplex();
testComplex_deser.deserialize(new BabelDataReader(ca));

compare_list(testComplex_ser.list1, testComplex_deser.list1);
compare_list(testComplex_ser.list2, testComplex_deser.list2);
compare_map1(testComplex_ser.map1, testComplex_deser.map1);
compare_map2(testComplex_ser.map2, testComplex_deser.map2);

function compare_list(lst_1, lst_2){
  assert.equal(lst_1.length, lst_2.length)
  for (var i = 0; i < lst_1.length; i++){
    assert.equal(lst_1[i], lst_2[i]);
  }
}

function compare_map1(map_1, map_2){
  for (var m in map_1) {
    assert.equal(map_1[m], map_2[m]);
  }
}

function compare_map2(map_1, map_2){
  for (var m in map_1) {
    assert.equal(map_1[m].length, map_2[m].length);
  }
}


