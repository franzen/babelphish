eval(require('fs').readFileSync('test/signed_int_test/js_test/test_signed_int.js', 'utf8'));
var fs = require('fs');
var assert = require('assert');

console.log("Test Signed Int");

var obj_ser = buildObject();

var ca = obj_ser.serialize();
serialize(ca);
var read = deserialize();

var obj_deser = new SignedInt();
obj_deser.deserialize(new DivineDataReader(read));
//compare_list(obj_ser.list1, obj_deser.list1);
compare_list(obj_ser.list2, obj_deser.list2);

function buildObject(){
  var obj  = new SignedInt();
  obj.list1   = [-1, -2, -3, Math.pow(2, 31)-1, Math.pow(2, 32-1) - Math.pow(2, 32)];
  obj.list2   = [-1, -2, -3, Math.pow(2, 54-1)-1, Math.pow(2, (54-1)) - Math.pow(2, 54)];
  return obj;
}

function compare_list(lst_1, lst_2){
  assert.equal(lst_1.length, lst_2.length)
  for (var i = 0; i < lst_1.length; i++){
    //console.log("Ser = " + lst_1[i] + ", Deser = " + lst_2[i]);
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
