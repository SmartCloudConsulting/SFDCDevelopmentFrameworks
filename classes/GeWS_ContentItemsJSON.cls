/**********************************************************************
Name:  GeWS_ContentItemsJSON
Copyright © 2016
======================================================
======================================================
Purpose:  Wrapper Class to convert Twitter Response Json and IBM Input JSON                                                         
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0      Ranjan Kumar       13th Sept 2016         
***********************************************************************/ 
public class GeWS_ContentItemsJSON{
  
  public List<ContentItem> contentItems;
  
  public class ContentItem {
    public String id;  //245160944223793152
    public String userid;  //bob
    public String sourceid;  //twitter
    public Integer created;  //1427720427
    public Integer updated;  //1427720427
    public String contenttype;  //text/plain
    public String charset;  //UTF-8
    public String language;  //en-us
    public String content;  //This is a sample tweet
    public String parentid;  
    public boolean reply;
    public boolean forward;  
  }
  /*******************Deserialize json into this class format*********************/
  public static GeWS_ContentItemsJSON parse(String json){
    return (GeWS_ContentItemsJSON) System.JSON.deserialize(json, GeWS_ContentItemsJSON.class);
  }
}