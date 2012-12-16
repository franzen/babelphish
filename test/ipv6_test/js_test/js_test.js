eval(require('fs').readFileSync('./test_ipv6.js', 'utf8'));
var fs = require('fs');
var assert = require('assert');

var obj_ser = buildObject();

var ca = obj_ser.serialize();
serialize(ca);
var read = deserialize();

var obj_deser = new IPV6();
obj_deser.deserialize(new BabelDataReader(read));
compare(obj_ser, obj_deser);

function buildObject(){
  var obj  = new IPV6();
  obj.ip   = "255.102.0.25";
// Should Success
//  obj.ipv6 = "ff:fabf:faf:f15f:f1ff:f2f:1f:f2";
//  obj.ipv6 = "2001:db8::ff00:1:8329";
//  obj.ipv6 = "F::";
//  obj.ipv6 = "1::";
//  obj.ipv6 = "::1";
//  obj.ipv6 = "";
		    
// Should Fail or raise error
//  obj.ipv6 = "2001:0db8:0000:0000:0000:ff00:0042:8329";
//  obj.ipv6 = "2001:db8:::ff00:42:8329";
//  obj.ipv6 = "2001:db8::fff00:42:8329";
//  obj.ipv6 = "2001:db8::fff00::42:8329";
//  obj.ipv6 = "2001:db8:ff00:42:8329";
//  obj.ipv6 = "::";
  return obj;
}

function compare(obj1, obj2){
  console.log(obj1.ipv6);
  console.log(obj2.ipv6);
  assert.equal(obj1.ip, obj2.ip);
  assert.equal(obj1.ipv6, obj2.ipv6);
}

function serialize(obj){
  var bBuffer = new Buffer(obj);
  fs.writeFileSync(__dirname +  '/bin.babel.js', bBuffer, function (err) {
    if (err) {
      return console.log(err);
    }
  });
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
