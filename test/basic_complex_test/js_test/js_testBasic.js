eval(require('fs').readFileSync('test/basic_complex_test/js_test/test_babel.js', 'utf8')); 
var assert = require('assert');
var fs = require('fs');

console.log("Basic Test");

var testBasic_ser  = new TestBasic();
testBasic_ser.i8   = 10;
testBasic_ser.i16  = 100;
testBasic_ser.i32  = 10000;
testBasic_ser.str  = "Test String";
testBasic_ser.guid = [1,15,4];

var ca = testBasic_ser.serialize();

serialize(ca);
var read = deserialize();


var testBasic_deser = new TestBasic();
testBasic_deser.deserialize(new DivineDataReader(read));

assert.equal(testBasic_ser.i8, testBasic_deser.i8);
assert.equal(testBasic_ser.i16, testBasic_deser.i16);
assert.equal(testBasic_ser.i32, testBasic_deser.i32);
assert.equal(testBasic_ser.str, testBasic_deser.str);
compare_list(testBasic_ser.guid, testBasic_deser.guid);

function compare_list(lst_1, lst_2){
  assert.equal(lst_1.length, lst_2.length)
  for (var i = 0; i < lst_1.length; i++){
    assert.equal(lst_1[i], lst_2[i]);
  }
}

function serialize(obj){
  var bBuffer = new Buffer(obj);
  fs.writeFileSync(__dirname +  '/bin.babel.js', bBuffer);
}

function deserialize(){
  var data = fs.readFileSync(__dirname +  '/bin.babel.js');
  data = toArray(data);
  return data;
  
}

function toArray(buffer) {
    var view = new Uint8Array(buffer.length);
    for (var i = 0; i < buffer.length; ++i) {
        view[i] = buffer[i];
    }
    return view;
}
