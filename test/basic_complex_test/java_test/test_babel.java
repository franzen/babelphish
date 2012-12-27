import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.regex.Pattern;
import java.nio.charset.Charset;

abstract class BabelBase  {
	private static final Charset UTF8 = Charset.forName("UTF-8");

	public byte[] serialize() throws IOException {
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		serializeInternal(baos);
		baos.close();
		return baos.toByteArray();
	}

	abstract void serializeInternal(ByteArrayOutputStream baos) throws IOException;

	abstract void deserialize(ByteArrayInputStream baos) throws IOException;

	protected int readInt8(ByteArrayInputStream data) {
		return data.read() & 0xff;
	}

	protected int readInt16(ByteArrayInputStream data) {
		return (data.read() << 8) | readInt8(data);
	}

	protected int readInt24(ByteArrayInputStream data) {
		return (data.read() << 16) | readInt16(data);
	}

	protected long readInt32(ByteArrayInputStream data) {
		return (data.read() << 24) | readInt24(data);
	}

	protected int readSint32(ByteArrayInputStream data) {
		return (data.read() << 24) | readInt24(data);
	}

	protected boolean readBool(ByteArrayInputStream data) {
		return readInt8(data) == 1;
	}

	protected String readString(ByteArrayInputStream data) throws IOException {
		// Force utf8
		return new String(readBytes(readInt16(data), data), UTF8);
	}

	private byte[] readBytes(int size, ByteArrayInputStream data) throws IOException {
		byte[] bs = new byte[size];
		data.read(bs);
		return bs;
	}

	protected byte[] readBinary(ByteArrayInputStream data) throws IOException {
		long c = readInt32(data);
		if (c > Integer.MAX_VALUE) {
			throw new IndexOutOfBoundsException("Binary data to big for java");
		}
		return readBytes((int) c, data);
	}

	protected byte[] readShortBinary(ByteArrayInputStream data) throws IOException {
		return readBytes(readInt8(data), data);
	}

	protected String readIpNumber(ByteArrayInputStream data) throws IOException {
		byte[] ips = readShortBinary(data);		
		if(ips.length == 4){
			return readIpv4Number(ips);
		} else{
			return readIpv6Number(ips);
		}
	}

	protected String readIpv4Number(byte[] ips){
		String ip = "";
		for (byte b : ips) {
			if (ip.length() > 0) {
				ip += ".";
			}
			ip += (b & 0xFF);
		}
		return ip;
	}

	protected String readIpv6Number(byte[] ips) throws IOException {
		String ip = "";
                int part1, part2;
		for (int i = 0; i < ips.length; i+=2) {
			part1   = ips[i] & 0xFF;
			part2   = ips[i+1] & 0xFF;
			ip += part1 == 0? "" : Integer.toHexString(part1);
			ip += (part1 == 0 && part2 == 0)? "" : (part2 < 10 && part1 != 0? "0" + Integer.toHexString(part2): Integer.toHexString(part2));
			if (i < ips.length-2) {
				ip += ":";
			}
		}
		ip = ip.replaceAll(":{3,}", "::");
		return ip;
	}

	protected void writeInt8(int v, ByteArrayOutputStream out) {
		if (v > 0xFF) { // Max 255
			raiseError("Too large int8 number: " + v);
		}else if(v < 0){
			raiseError("a negative number passed  to int8 number: " + v);
		}
		out.write(v);
	}

	protected void writeInt16(int v, ByteArrayOutputStream out) {
		if (v > 0xFFFF) { // Max 65.535 
			raiseError("Too large int16 number: " + v);
		}else if(v < 0){
			raiseError("a negative number passed  to int16 number: " + v);
		}
		writeInt8(v >> 8 & 0xFF, out);
		writeInt8(v & 0xFF, out);
	}

	protected void writeInt24(int v, ByteArrayOutputStream out) {
		if (v > 0xFFFFFF) { 	// Max 16.777.215
			raiseError("Too large int24 number: " + v);
		}else if(v < 0){	// In Case added to Java declaration
			raiseError("a negative number passed  to int24 number: " + v);
		}
		writeInt8(v >> 16 & 0xFF, out);
		writeInt16(v & 0xFFFF, out);
	}

	protected void writeInt32(long v, ByteArrayOutputStream out) {
		if (v > 0xFFFFFFFFL) { // Max 4.294.967.295
			raiseError("Too large int32 number: " + v);
		}else if(v < 0){
			raiseError("a negative number passed  to int32 number: " + v);
		}
		writeInt8((int) ((v >> 24) & 0xFF), out);
		writeInt24((int) (v & 0xFFFFFF), out);
	}

        protected void writeSint32(int v, ByteArrayOutputStream out) {
		if (v > Integer.MAX_VALUE) { 		// Max  2.147.483.647
			raiseError("Too large sInt32 number: " + v + ", Max = " + Integer.MAX_VALUE);
		}else if(v < Integer.MIN_VALUE){ 	// Min -2.147.483.648
			raiseError("Too small sInt32 number: " + v + ", Min = " + Integer.MIN_VALUE);
		}
		writeInt8((int) ((v >> 24) & 0xFF), out);
		writeInt24((int) (v & 0xFFFFFF), out);
	}

	protected void writeBool(boolean v, ByteArrayOutputStream out) {
		writeInt8(v ? 1 : 0, out);
	}

	protected void writeString(String v, ByteArrayOutputStream out) throws IOException {
		byte[] bs = v.getBytes(UTF8);
		if (bs.length > 0xFFFF) {
			raiseError("Too large string: " + bs.length + " bytes");
		}
		writeInt16(bs.length, out);
		out.write(bs);
	}

	protected void writeBinary(byte[] v, ByteArrayOutputStream out) throws IOException {
		if (v.length > 0xFFFFFFFFL) {
			raiseError("Too large binary: " + v.length + " bytes");
		}
		writeInt32(v.length, out);
		out.write(v);
	}


	protected void write16Binary(int[] v, ByteArrayOutputStream out) throws IOException {
		if (v.length > 0xFF) {
			raiseError("Too large 16_binary: " + (v.length*2) + " bytes");
		}
		writeInt8(v.length*2, out);
		for(int i = 0; i < v.length; i++){
			this.writeInt16(v[i], out);
		}
	}

	protected void writeShortBinary(byte[] v, ByteArrayOutputStream out) throws IOException {
		if (v.length > 0xFF) {
			raiseError("Too large short_binary: " + v.length + " bytes");
		}
		writeInt8(v.length, out);
		out.write(v);
	}

	protected void writeIpNumber(String v, ByteArrayOutputStream out) throws IOException {
		if(v.contains(":")){
			writeIpv6Number( v, out);
		}else{
			writeIpv4Number( v, out);
    		}
	}
        
        protected void writeIpv4Number(String v, ByteArrayOutputStream out) throws IOException {
		byte[] ss = new byte[0];
		if(!v.isEmpty()){
			String[] bs = v.split("\\.");
			ss = new byte[bs.length];
			for (int i = 0; i < bs.length; i++) {
				ss[i] = (byte) (Integer.parseInt(bs[i]) & 0xFF);
			}
		}
		if (ss.length == 0 || ss.length == 4) {
			writeShortBinary(ss, out);
		} else {
			raiseError("Unknown IP v4 number " + v); // Only IPv4 for now 
		}
	}

        protected void writeIpv6Number(String v, ByteArrayOutputStream out)
			throws IOException {
		v = v.replaceAll(" ", "") + " "; // Temporary: To avoid the split problem when we have : at the
					// end of "v"
		int[] ss = new int[0];
		boolean contains_ipv6_letters = Pattern.compile("[0-9a-f]+").matcher(
				v.trim().toLowerCase()).find();
		boolean contains_other_letters = Pattern.compile("[^:0-9a-f]+")
				.matcher(v.trim().toLowerCase()).find();
		// make sure of v must have only one "::" and no more than two of ":".
		// e.g. 1::1::1 & 1:::1:205
		if (!v.trim().isEmpty() && v.split(":{3,}").length == 1
				&& v.split(":{2}").length <= 2 && !contains_other_letters
				&& contains_ipv6_letters) {
			String[] bs = v.split(":");
			ss = new int[bs.length];
			for (int i = 0; i < bs.length; i++) {
				String s = bs[i].trim();
				if (s.length() <= 4) // to avoid such number 0125f
					ss[i] = Integer.parseInt(
							(s.isEmpty() ? "0" : bs[i].trim()), 16);
				else
					raiseError("Unknown IPv6 Group " + i + " which is " + s);
			}
		}
		// Check for make sure of the size of the IP groups in case "::" is used
		// [> 2 & < 8]or not [must == 8]
		if (!contains_other_letters
				&& (!v.contains("::") && ss.length == 0 || ss.length == 8)
				|| (v.contains("::") && ss.length > 2 && ss.length < 8)) {
			write16Binary(ss, out);
		} else {
			raiseError("Unknown IP v6 number " + v);
		}
	}

	protected void raiseError(String msg) {
		throw new IllegalArgumentException("[" + this.getClass().getCanonicalName() + "] " + msg);
	}
}


class Entry extends BabelBase {

	@Override
	void serializeInternal(ByteArrayOutputStream baos) throws IOException {
	}

	@Override
	public void deserialize(ByteArrayInputStream bais) throws IOException {
	}
}


class TestBasic extends BabelBase {
	public int i8 = 0;
	public int i16 = 0;
	public long i32 = 0L;
	public String str = "";
	public String ip = "";
	public byte[] guid = new byte[0];

	@Override
	void serializeInternal(ByteArrayOutputStream baos) throws IOException {
		writeInt8(this.i8, baos);
		writeInt16(this.i16, baos);
		writeInt32(this.i32, baos);
		writeString(this.str, baos);
		writeIpNumber(this.ip, baos);
		writeBinary(this.guid, baos);
	}

	@Override
	public void deserialize(ByteArrayInputStream bais) throws IOException {
		this.i8 = readInt8(bais);
		this.i16 = readInt16(bais);
		this.i32 = readInt32(bais);
		this.str = readString(bais);
		this.ip = readIpNumber(bais);
		this.guid = readBinary(bais);
	}
}


class TestComplex extends BabelBase {
	public ArrayList<Long> list1 = new ArrayList<Long>();
	public ArrayList<Integer> list2 = new ArrayList<Integer>();
	public HashMap<Integer, Long> map1 = new HashMap<Integer, Long>();
	public HashMap<String, ArrayList<Entry>> map2 = new HashMap<String, ArrayList<Entry>>();

	@Override
	void serializeInternal(ByteArrayOutputStream baos) throws IOException {
		// Serialize list 'list1'
		writeInt32(list1.size(), baos);
		for(int var_101=0; var_101<list1.size(); var_101++) {
			long var_100 = list1.get(var_101);
			writeInt32(var_100, baos);
		}
		// Serialize list 'list2'
		writeInt32(list2.size(), baos);
		for(int var_103=0; var_103<list2.size(); var_103++) {
			int var_102 = list2.get(var_103);
			writeInt8(var_102, baos);
		}
		// Serialize map 'map1'
		writeInt32(map1.size(), baos);
		for(int var_104 : map1.keySet()) {
			long var_105 = map1.get(var_104);
			writeInt8(var_104, baos);
			writeInt32(var_105, baos);
		}
		// Serialize map 'map2'
		writeInt32(map2.size(), baos);
		for(String var_106 : map2.keySet()) {
			ArrayList<Entry> var_107 = map2.get(var_106);
			writeString(var_106, baos);
			writeInt32(var_107.size(), baos);
			for(int var_109=0; var_109<var_107.size(); var_109++) {
				Entry var_108 = var_107.get(var_109);
				var_108.serializeInternal(baos);
			}
		}
	}

	@Override
	public void deserialize(ByteArrayInputStream bais) throws IOException {
		// Deserialize list 'list1'
		this.list1 = new ArrayList<Long>();
		int var_10a = (int)this.readInt32(bais);
		for(int var_10c=0; var_10c<var_10a; var_10c++) {
			long var_10b = readInt32(bais);
			this.list1.add(var_10b);
		}
		// Deserialize list 'list2'
		this.list2 = new ArrayList<Integer>();
		int var_10d = (int)this.readInt32(bais);
		for(int var_10f=0; var_10f<var_10d; var_10f++) {
			int var_10e = readInt8(bais);
			this.list2.add(var_10e);
		}
		// Deserialize map 'map1'
		this.map1 = new HashMap<Integer, Long>();
		int var_110 = (int)readInt32(bais);
		for(int var_113=0; var_113<var_110; var_113++) {
			int var_111 = readInt8(bais);
			long var_112 = readInt32(bais);
			this.map1.put(var_111, var_112);
		}
		// Deserialize map 'map2'
		this.map2 = new HashMap<String, ArrayList<Entry>>();
		int var_114 = (int)readInt32(bais);
		for(int var_117=0; var_117<var_114; var_117++) {
			String var_115 = readString(bais);
			ArrayList<Entry> var_116 = new ArrayList<Entry>();
			int var_118 = (int)this.readInt32(bais);
			for(int var_11a=0; var_11a<var_118; var_11a++) {
				Entry var_119 = new Entry();
				var_119.deserialize(bais);
				var_116.add(var_119);
			}
			this.map2.put(var_115, var_116);
		}
	}
}
