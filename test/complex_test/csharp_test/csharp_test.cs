using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using divine;
using NUnit.Framework;

namespace test_signed_int
{
    [TestFixture]
    class divine
    {
        [Test]
        public static void Main(String[] args)
        {
	    System.Console.Write("Test Complex Data Structure  \n");
            Complex ser = buildObj();
            serialize(ser);
            byte[] res = deserialize();

            Complex deser = new Complex();
            deser.deserialize(new MemoryStream(res));

            compare(ser, deser);            
        }

        public static Complex buildObj() {
	    	IPList ipList_1 = new IPList();
	    	ipList_1.list1.Add("10.2.2.1");
	    	ipList_1.list1.Add("127.0.0.1");
		ipList_1.list1.Add("129.36.58.15");

		ipList_1.list2.Add("2001:db8::ff00:1:8329");
		ipList_1.list2.Add("ff:ac:12::5f");
		ipList_1.list2.Add("1::");
		
		IPList ipList_2 = new IPList();
		ipList_2.list1.Add("100.20.20.10");
		ipList_2.list1.Add("17.10.10.1");
		ipList_2.list1.Add("12.36.68.105");

		ipList_2.list2.Add("ff:fabf:faf:f15f:f1ff:f2f:1f:f2");
		ipList_2.list2.Add("2001:db8::ff00:1:8329");
		ipList_2.list2.Add("::1");
		

                List<IPList> tmp1 = new List<IPList>();
		tmp1.Add(ipList_1);
		tmp1.Add(ipList_2);

                List<IPList> tmp2 = new List<IPList>();
		tmp2.Add(ipList_2);
		tmp2.Add(ipList_1);

		Dictionary<string, List<IPList>> dict1 = new Dictionary<string, List<IPList>>();
		dict1.Add("AA", tmp1);

		Dictionary<string, List<IPList>> dict2 = new Dictionary<string, List<IPList>>();
		dict2.Add("BB", tmp2);
		
		Complex com = new Complex();
		com.list1.Add(dict1);
		com.list1.Add(dict2);

		return com;
	}

        public static void compare(Complex obj1, Complex obj2)
        {
		Assert.AreEqual(obj1.list1.Count, obj2.list1.Count);
		Assert.AreEqual(obj1.list1[0]["AA"].Count,
				obj2.list1[0]["AA"].Count);
		Assert.AreEqual(obj1.list1[0]["AA"][0].list1
				.Count, obj2.list1[0]["AA"][0].list1.Count);
		Assert.AreEqual(obj1.list1[0]["AA"][0].list1
				[2].ToLower(), obj2.list1[0]["AA"][0].list1[2].ToLower());
		Assert.AreEqual(obj1.list1[0]["AA"][0].list2
				[1].ToLower(), obj2.list1[0]["AA"][0].list2[1].ToLower());
		Assert.AreEqual(obj1.list1[1]["BB"][0].list2
				[0].ToLower(), obj2.list1[1]["BB"][0].list2[0].ToLower());
        }

        public static void serialize(Divine obj)
        {
            try
            {
                byte[] data = obj.serialize();
                File.WriteAllBytes("test/complex_test/csharp_test/bin.babel.csharp", data);                
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
	    }

	    public static byte[] deserialize(){
            try
            {
                byte[] data = File.ReadAllBytes("test/complex_test/csharp_test/bin.babel.csharp");
                return data;
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
	    }
            
    }
}
