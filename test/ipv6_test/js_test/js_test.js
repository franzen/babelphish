eval(require('fs').readFileSync('test/ipv6_test/js_test/test_ipv6.js', 'utf8'));
var fs = require('fs');
var assert = require('assert');

console.log("Test IPv6");

var obj_ser = buildObject();

var ca = obj_ser.serialize();
serialize(ca);
var read = deserialize();

var obj_deser = new IPV6();
obj_deser.deserialize(new DivineDataReader(read));
compare_list(obj_ser.list1, obj_deser.list1);

function buildObject(){
  var obj  = new IPV6();
  obj.list1   = ["255.102.0.25","ff:fabf:faf:f15f:f1ff:f2f:1f:f2","2001:db8::ff00:1:8329","f::","::1",""]
		    
// Should Fail or raise error
//  obj.ip = "2001:0db8:0000:0000:0000:ff00:0042:8329";
//  obj.ip = "2001:db8:::ff00:42:8329";
//  obj.ip = "2001:db8::fff00:42:8329";
//  obj.ip = "2001:db8::fff00::42:8329";
//  obj.ip = "2001:db8:ff00:42:8329";
//  obj.ip = "::";
  return obj;
}

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
