global abstract class ZendeskResourceBase extends ZendeskTypes {

    protected final ZendeskConnection zconn;

    global ZendeskResourceBase(ZendeskConnection zconn) {
        this.zconn = zconn;
    }


    // Realllly hacky way of stripping out nulls. 
    // https://iwritecrappycode.wordpress.com/2014/07/16/stripping-nulls-from-a-json-object-in-apex/
    // This is now replaced with JSON.serialize(object, suppressApexObjectNulls=true);
    // but we can't delete this method since it's part of a managed package
    global static string stripJsonNulls(String jsonString) {
        if (!String.isEmpty(jsonString)) {
            jsonString = jsonString.replaceAll('\"[^\"]*\":null',''); // basic removal of null values
            jsonString = jsonString.replaceAll(',{2,}', ','); // remove duplicate/multiple commas
            jsonString = jsonString.replace('{,', '{'); // prevent opening brace from having a comma after it
            jsonString = jsonString.replace(',}', '}'); // prevent closing brace from having a comma before it
            jsonString = jsonString.replace('[,', '['); // prevent opening bracket from having a comma after it
            jsonString = jsonString.replace(',]', ']'); // prevent closing bracket from having a comma before it
        }
        return jsonString;
    }

    global static Long getUnixEpochTime(DateTime dt) {
       return (dt == null ? null : (dt.getTime() / 1000));
    }

    global static String urlEncode(String str) {
        return (str == null ? null : EncodingUtil.urlEncode(str, 'UTF-8'));
    }

    global static String toCSV(List<Long> longs) {
        String csv = '';
        if (longs != null && !longs.isEmpty()) {
            for (Long l : longs) { csv += l + ','; }
            csv = csv.removeEnd(',');
        }
        return csv;
    }

    global static String toCSV(Set<Long> longs) {
        String csv = '';
        if (longs != null && !longs.isEmpty()) {
            for (Long l : longs) { csv += l + ','; }
            csv = csv.removeEnd(',');
        }
        return csv;
    }

    global static String toCSV(Set<String> strings) {
        String csv = '';
        if (strings != null && !strings.isEmpty()) {
            for (String str : strings) { csv += str + ','; }
            csv = csv.removeEnd(',');
        }
        return csv;
    }
}
