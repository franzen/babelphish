eval(require('fs').readFileSync('./test_binaryTree.js', 'utf8')); 
var assert = require('assert');

var binaryTree_ser = buildTree();
var ca = binaryTree_ser.serialize();
var binaryTree_deser = new BinaryTree();
binaryTree_deser.deserialize(new BabelDataReader(ca));
compareBinaryTree(binaryTree_ser, binaryTree_deser);


function buildTree(){
    var root = new Node();
    root.i32 = 0;
    
    var n1_L = new Node();
    n1_L.i32 = 1;

    var n1_R = new Node();
    n1_R.i32 = 2;

    var n2_L_L = new Node();
    n2_L_L.i32 = 3;

    var n2_L_R = new Node();
    n2_L_R.i32 = 4;

    var n2_R_L = new Node();
    n2_R_L.i32 = 5;

    var n2_R_R = new Node();
    n2_R_R.i32 = 6;

    root.next_node = [n1_L, n1_R];
    n1_L.next_node = [n2_L_L, n2_L_R];
    n1_R.next_node = [n2_R_L, n2_R_R];
    
    var bt = new BinaryTree();
    bt.root_node = [root];
    return bt;
}

function compareBinaryTree(bt1, bt2){
  assert.equal( bt1.root_node.length, bt2.root_node.length);
  assert.equal( bt1.root_node[0].i32, bt2.root_node[0].i32);
  assert.equal( bt1.root_node[0].next_node.length, bt2.root_node[0].next_node.length);
  assert.equal( bt1.root_node[0].next_node[0].next_node[0].i32, bt2.root_node[0].next_node[0].next_node[0].i32);
}


