<?xml version="1.0" encoding="EUC-JP"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <xsl:output method="html" encoding="EUC-JP"
              doctype-public="-//W3C//DTD HTML 4.01//EN"/>

  <xsl:template match="/">
    <html lang="ja">
      <head>
        <title>WikiClone�����</title>
        <link rel="stylesheet" href="../default.css"/>
        <!--<script type="text/javascript" src="highlight.js"/>-->
        <style type="text/css">
          td {
            text-align: center;
          /* border: thin solid gray; */
          }
          th { border-bottom: thin solid gray; }
          table { border: thin solid gray; }
        </style>
      </head>
      <body>
        <h1><a name="top">WikiClone�����</a></h1>
        <p>
          �Ƽ�WikiClone�ε�ǽ��Ӥ򤷤ޤ���
        </p>
        <xsl:apply-templates/>
        <hr/>
        <h2><a name="field">��ӹ���</a></h2>
        <ul>
          <li><a name="implementation">����</a>:
          �ɤ�ʸ��졦�Ķ��ǹ��ۤ���Ƥ��뤫��</li>
          <li><a name="backend">��¸����</a>:
          Wiki�Υǡ����ݻ��ˤɤΤ褦�ʵ������Ѥ��Ƥ��뤫��</li>
          <li><a name="japanese">���ܸ��б�</a>:
          ���ܸ���б����Ƥ��뤫���ä�WikiName�Ȥ������ܸ��Ȥ��뤫��</li>
          <li><a name="history">����</a>:
          �����Խ����������Ǥ��뤫��</li>
          <li><a name="interwikiname">InterWikiName</a>:
          ������Wiki�ʤɤؤ�Wiki���Ȥ���ǽ����</li>
          <li><a name="link-in-page">�ڡ�������</a>:
          �ڡ�����ΰ���ʬ�ؤΥ�󥯤�ĥ��뤫��</li>
          <li><a name="world-link">������󥯤ζ���</a>:
          �����ؤΥ�󥯤���̤���ɽ�����뤫��</li>
          <li><a name="table">�ơ��֥�</a>:
          ɽ�Ȥߤ��б����Ƥ��뤫��</li>
          <li><a name="html">HTML</a>:
          ����HTML�򤽤Τޤ޵��ҤǤ��뤫��</li>
          <li><a name="upload">���åץ���</a>:
          Ǥ�դΥե�����ʲ����Ȥ��ˤ򥢥åץ��ɤ��ơ�
          �ڡ�����ź�դǤ��뤫��</li>
          <li><a name="changelog">�Խ���</a>:
          �Խ������ݤˡ������ѹ����ƤˤĤ��ƤΥ����Ȥ��դ����뤫��</li>
          <li><a name="acl">������������</a>:
          �桼���Υ�����������������Ǥ��뤫����å���ǽ</li>
          <li><a name="notify">�ѹ�����</a>:
          �ڡ������Խ����줿���ˡ��᡼��ʤɤǤ����Τ�����뤫��</li>
          <li><a name="plugin">�ץ饰����</a>:
          �ü�ʽ񼰡���ǽ��ץ饰����ʤɤȤ��ơ��ɲäǤ��뤫��</li>
        </ul>
        <hr/>
        <address>
          ��ײ��� (TAKAKU Masao)<br/>
          <a href="http://nile.ulis.ac.jp/~masao/">http://nile.ulis.ac.jp/~masao/</a>,
          <a href="mailto:masao@nii.ac.jp">masao@nii.ac.jp</a>
        </address>
        <script type="text/javascript">
          var hiliteStyle = new Object();
          hiliteStyle.color = "black";
          hiliteStyle.backgroundColor = "yellow";
          
          var hiliteElem = null;
          var saveStyle = null;
		
          function hiliteElement(name)
          {
            if( hiliteElem ){
              for (var key in saveStyle){
                hiliteElem.style[key] = saveStyle[key];
              }
              hiliteElem = null;
            }
		
            hiliteElem = getHiliteElement(name);
            if ( !hiliteElem ) return;
		
            saveStyle = new Object();
            for (var key in hiliteStyle){
              saveStyle[key] = hiliteElem.style[key];
              hiliteElem.style[key] = hiliteStyle[key];
            }
          }
		
          function getHiliteElement(name)
          {
            for (i=0; i&lt;document.anchors.length; ++i) {
              var anchor = document.anchors[i];
	      if ( anchor.name == name ) {
	        var elem;
                if ( anchor.parentElement ) {
                  elem = anchor.parentElement;
                } else if ( anchor.parentNode ) {
                  elem = anchor.parentNode;
		}
		return elem;
	      }
            }
            return null;
          }
		
          if( document.location.hash ){
            hiliteElement(document.location.hash.substr(1));
          }
		
          hereURL = document.location.href.split("#")[0];
          for( var i = 0; i &lt; document.links.length; i++ ){
            if( hereURL == document.links[i].href.split("#")[0] ){
              document.links[i].onclick = handleLinkClick;
            }
          }
		
          function handleLinkClick()
          {
            hiliteElement(this.hash.substr(1));
          }
        </script>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="summary-table">
    <table summary="WikiClone�����ɽ">
      <thead>
        <tr>
          <th>̾��</th>
          <th><a href="#implementation">����</a></th>
          <th><a href="#backend">��¸����</a></th>
          <th><a href="#japanese">���ܸ�</a></th>
          <th><a href="#history">����</a></th>
          <th><a href="#interwikiname">InterWikiName</a></th>
          <th><a href="#link-in-page">�ڡ�������</a></th>
          <th><a href="#table">ɽ�Ȥ�</a></th>
          <th><a href="#html">HTML</a></th>
          <th><a href="#upload">���åץ���</a></th>
          <th><a href="#acl">������������</a></th>
          <th><a href="#notify">�᡼������</a></th>
          <th><a href="#plugin">�ץ饰����</a></th>
        </tr>
      </thead>
      <xsl:for-each select="engine">
        <tr>
          <td><a href="#{@id}"><xsl:value-of select="@title"/></a></td>
          <td><xsl:value-of select="implementation/@label"/></td>
          <td><xsl:value-of select="backend/@label"/></td>
          <td><xsl:value-of select="japanese/@label"/></td>
          <td><xsl:value-of select="history/@label"/></td>
          <td><xsl:value-of select="interwikiname/@label"/></td>
          <td><xsl:value-of select="link-in-page/@label"/></td>
          <td><xsl:value-of select="table/@label"/></td>
          <td><xsl:value-of select="html/@label"/></td>
          <td><xsl:value-of select="upload/@label"/></td>
          <td><xsl:value-of select="acl/@label"/></td>
          <td><xsl:value-of select="notify/@label"/></td>
          <td><xsl:value-of select="plugin/@label"/></td>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>
  
  <xsl:template match="wikiwiki-cmp">
    <xsl:call-template name="summary-table" />
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="engine">
    <hr/>
    <h2><a name="{@id}" href="{@href}"><xsl:value-of select="@title"/></a></h2>
    <p><xsl:value-of select="description"/></p>
    <ul>
      <xsl:apply-templates select="implementation|japanese|history|interwikiname|link-in-page|world-link|table|html|upload|acl|notify|plugin"/>
    </ul>
  </xsl:template>

  <xsl:template match="link">
    <div>��Ϣ���: <a href="{@href}" title="{@title}"><xsl:value-of select="."/></a></div>
  </xsl:template>

  <xsl:template match="implementation">
    <li>��������: <xsl:value-of select="@label"/>
    <xsl:if test="string-length(.)">
      <br/><xsl:apply-templates/>
    </xsl:if>
    </li>
  </xsl:template>
  <xsl:template match="backend">
    <li>��¸����: <xsl:value-of select="@label"/>
    <xsl:if test="string-length(.)">
      <br/><xsl:apply-templates/>
    </xsl:if>
    </li>
  </xsl:template>
  <xsl:template match="japanese">
    <li>���ܸ��б�: <xsl:value-of select="@label"/>
    <xsl:if test="string-length(.)">
      <br/><xsl:apply-templates/>
    </xsl:if>
    </li>
  </xsl:template>
  <xsl:template match="history">
    <li>�������: <xsl:value-of select="@label"/>
    <xsl:if test="string-length(.)">
      <br/><xsl:apply-templates/>
    </xsl:if>
    </li>
  </xsl:template>
  <xsl:template match="interwikiname">
    <li>InterWikiName: <xsl:value-of select="@label"/>
    <xsl:if test="string-length(.)">
      <br/><xsl:apply-templates/>
    </xsl:if>
    </li>
  </xsl:template>
  <xsl:template match="link-in-page">
    <li>�ڡ�������: <xsl:value-of select="@label"/>
    <xsl:if test="string-length(.)">
      <br/><xsl:apply-templates/>
    </xsl:if>
    </li>
  </xsl:template>
  <xsl:template match="world-link">
    <li>�������: <xsl:value-of select="@label"/>
    <xsl:if test="string-length(.)">
      <br/><xsl:apply-templates/>
    </xsl:if>
    </li>
  </xsl:template>
  <xsl:template match="table">
    <li>ɽ�Ȥ�: <xsl:value-of select="@label"/>
    <xsl:if test="string-length(.)">
      <br/><xsl:apply-templates/>
    </xsl:if>
    </li>
  </xsl:template>
  <xsl:template match="html">
    <li>HTML: <xsl:value-of select="@label"/>
    <xsl:if test="string-length(.)">
      <br/><xsl:apply-templates/>
    </xsl:if>
    </li>
  </xsl:template>
  <xsl:template match="upload">
    <li>���åץ���: <xsl:value-of select="@label"/>
    <xsl:if test="string-length(.)">
      <br/><xsl:apply-templates/>
    </xsl:if>
    </li>
  </xsl:template>
  <xsl:template match="acl">
    <li>������������: <xsl:value-of select="@label"/>
    <xsl:if test="string-length(.)">
      <br/><xsl:apply-templates/>
    </xsl:if>
    </li>
  </xsl:template>
  <xsl:template match="notify">
    <li>�ѹ�����: <xsl:value-of select="@label"/>
    <xsl:if test="string-length(.)"><br/><xsl:apply-templates/></xsl:if>
    </li>
  </xsl:template>
  <xsl:template match="plugin">
    <li>�ץ饰����: <xsl:value-of select="@label"/>
    <xsl:if test="string-length(.)">
      <br/><xsl:apply-templates/>
    </xsl:if>
    </li>
  </xsl:template>
</xsl:stylesheet>
