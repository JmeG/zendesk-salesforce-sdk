public abstract class ZendeskResourceBase {

	protected final ZendeskAPI zapi;

    public ZendeskResourceBase(ZendeskAPI zapi) {
		this.zapi = zapi;
	}

    public static String toCSV(List<Long> longs) {
		String csv = '';
		if (longs != null && !longs.isEmpty()) {
			for (Long l : longs) { csv += l + ','; }
			csv = csv.removeEnd(',');
		}
		return csv;
	}

	public static String toCSV(Set<Long> longs) {
		String csv = '';
		if (longs != null && !longs.isEmpty()) {
			for (Long l : longs) { csv += l + ','; }
			csv = csv.removeEnd(',');
		}
		return csv;
	}

	public static String toCSV(Set<String> strings) {
		String csv = '';
		if (strings != null && !strings.isEmpty()) {
			for (String str : strings) { csv += str + ','; }
			csv = csv.removeEnd(',');
		}
		return csv;
	}
}
