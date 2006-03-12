<?xml version="1.0" encoding="EUC-JP"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <xsl:output method="html" encoding="EUC-JP"
              doctype-public="-//W3C//DTD HTML 4.01//EN"/>

  <xsl:template match="/">
    <html lang="ja">
      <head>
        <title>WikiCloneの比較</title>
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
        <h1><a name="top">WikiCloneの比較</a></h1>
        <p>
          各種WikiCloneの機能比較をします。
        </p>
        <xsl:apply-templates/>
        <hr/>
        <h2><a name="field">比較項目</a></h2>
        <ul>
          <li><a name="implementation">実装</a>:
          どんな言語・環境で構築されているか。</li>
          <li><a name="backend">保存形式</a>:
          Wikiのデータ保持にどのような機構を用いているか。</li>
          <li><a name="japanese">日本語対応</a>:
          日本語に対応しているか。特にWikiNameとして日本語を使えるか。</li>
          <li><a name="history">履歴</a>:
          過去の編集履歴を閲覧できるか。</li>
          <li><a name="interwikiname">InterWikiName</a>:
          外部のWikiなどへのWiki参照が可能か。</li>
          <li><a name="link-in-page">ページ内リンク</a>:
          ページ内の一部分へのリンクを張れるか。</li>
          <li><a name="world-link">外部リンクの区別</a>:
          外部へのリンクを区別して表示するか。</li>
          <li><a name="table">テーブル</a>:
          表組みに対応しているか。</li>
          <li><a name="html">HTML</a>:
          生のHTMLをそのまま記述できるか。</li>
          <li><a name="upload">アップロード</a>:
          任意のファイル（画像とか）をアップロードして、
          ページに添付できるか。</li>
          <li><a name="changelog">編集ログ</a>:
          編集した際に、その変更内容についてのコメントを付けられるか。</li>
          <li><a name="acl">アクセス制御</a>:
          ユーザのアクセス状況を管理できるか。ロック機能</li>
          <li><a name="notify">変更通知</a>:
          ページが編集された場合に、メールなどでの通知がされるか。</li>
          <li><a name="plugin">プラグイン</a>:
          特殊な書式・機能をプラグインなどとして、追加できるか。</li>
        </ul>
        <hr/>
        <address>
          高久雅生 (TAKAKU Masao)<br/>
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
    <table summary="WikiCloneの比較表">
      <thead>
        <tr>
          <th>名称</th>
          <th><a href="#implementation">実装</a></th>
          <th><a href="#backend">保存形式</a></th>
          <th><a href="#japanese">日本語</a></th>
          <th><a href="#history">履歴</a></th>
          <th><a href="#interwikiname">InterWikiName</a></th>
          <th><a href="#link-in-page">ページ内リンク</a></th>
          <th><a href="#table">表組み</a></th>
          <th><a href="#html">HTML</a></th>
          <th><a href="#upload">アップロード</a></th>
          <th><a href="#acl">アクセス制御</a></th>
          <th><a href="#notify">メール通知</a></th>
          <th><a href="#plugin">プラグイン</a></th>
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
    <div>関連リンク: <a href="{@href}" title="{@title}"><xsl:value-of select="."/></a></div>
  </xsl:template>

  <xsl:template match="implementation">
    <li>実装言語: <xsl:value-of select="@label"/>
    <xsl:if test="string-length(.)">
      <br/><xsl:apply-templates/>
    </xsl:if>
    </li>
  </xsl:template>
  <xsl:template match="backend">
    <li>保存形式: <xsl:value-of select="@label"/>
    <xsl:if test="string-length(.)">
      <br/><xsl:apply-templates/>
    </xsl:if>
    </li>
  </xsl:template>
  <xsl:template match="japanese">
    <li>日本語対応: <xsl:value-of select="@label"/>
    <xsl:if test="string-length(.)">
      <br/><xsl:apply-templates/>
    </xsl:if>
    </li>
  </xsl:template>
  <xsl:template match="history">
    <li>履歴管理: <xsl:value-of select="@label"/>
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
    <li>ページ内リンク: <xsl:value-of select="@label"/>
    <xsl:if test="string-length(.)">
      <br/><xsl:apply-templates/>
    </xsl:if>
    </li>
  </xsl:template>
  <xsl:template match="world-link">
    <li>外部リンク: <xsl:value-of select="@label"/>
    <xsl:if test="string-length(.)">
      <br/><xsl:apply-templates/>
    </xsl:if>
    </li>
  </xsl:template>
  <xsl:template match="table">
    <li>表組み: <xsl:value-of select="@label"/>
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
    <li>アップロード: <xsl:value-of select="@label"/>
    <xsl:if test="string-length(.)">
      <br/><xsl:apply-templates/>
    </xsl:if>
    </li>
  </xsl:template>
  <xsl:template match="acl">
    <li>アクセス制御: <xsl:value-of select="@label"/>
    <xsl:if test="string-length(.)">
      <br/><xsl:apply-templates/>
    </xsl:if>
    </li>
  </xsl:template>
  <xsl:template match="notify">
    <li>変更通知: <xsl:value-of select="@label"/>
    <xsl:if test="string-length(.)"><br/><xsl:apply-templates/></xsl:if>
    </li>
  </xsl:template>
  <xsl:template match="plugin">
    <li>プラグイン: <xsl:value-of select="@label"/>
    <xsl:if test="string-length(.)">
      <br/><xsl:apply-templates/>
    </xsl:if>
    </li>
  </xsl:template>
</xsl:stylesheet>
