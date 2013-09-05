<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:hl="http://www.daimi.au.dk/CPnets/pnml/hlpn" xmlns:cpn="http://www.daimi.au.dk/CPNTools/hlpn">

	<xsl:variable name="lcletters">abcdefghijklmnopqrstuvwxyz</xsl:variable>
	<xsl:variable name="ucletters">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

	<xsl:template name='tolower'>
		<xsl:param name='toconvert' />
		<xsl:value-of select="translate($toconvert,$ucletters,$lcletters)"/>
	</xsl:template>

	<xsl:template match="workspaceElements">
		<hl:pnml xmlns="http://www.daimi.au.dk/CPnets/pnml/hlpn">
			<xsl:apply-templates select="node()|text()"/>
            </hl:pnml>
	</xsl:template>

	<xsl:template match="cpnet">
		<hl:net id="{generate-id()}" type="http://www.daimi.au.dk/CPnets/pnml/hlpn">
			<xsl:apply-templates select="node()|text()"/>
		</hl:net>
	</xsl:template>

	<xsl:template match="globbox">
		<hl:declarations>
			<xsl:apply-templates select="block|color" mode="decl"/>
		</hl:declarations>
	</xsl:template>

	<xsl:template match="block" mode="decl">
		<hl:toolspecific tool="CPN Tools" version="1.0.0">
			<cpn:startblock>
				<xsl:attribute name="name"><xsl:value-of select="id"/></xsl:attribute>
			</cpn:startblock>
		</hl:toolspecific>
		<xsl:apply-templates select="color" mode="decl"/>
		<hl:toolspecific tool="CPN Tools" version="1.0.0">
			<cpn:endblock/>
		</hl:toolspecific>
	</xsl:template>

	<xsl:template match="color" mode="decl">
		<hl:declaration>
			<hl:type>
				<xsl:apply-templates select="id" mode="decl"/>
				<hl:type>
					<xsl:apply-templates select="int|bool|string|enum|product" mode="decl"/>
				</hl:type>
			</hl:type>
		</hl:declaration>
	</xsl:template>

	<xsl:template match="color/id" mode="decl">
		<hl:name>
			<xsl:value-of select="text()"/>
		</hl:name>
	</xsl:template>

	<xsl:template match="int" mode="decl"><hl:int/></xsl:template>
	<xsl:template match="bool" mode="decl"><hl:bool/></xsl:template>
	<xsl:template match="string" mode="decl"><hl:string/></xsl:template>

	<xsl:template match="enum" mode="decl">
		<hl:enum>
			<xsl:apply-templates select="node()|text()" mode="decl"/>
		</hl:enum>
	</xsl:template>

	<xsl:template match="product" mode="decl">
		<hl:product>
			<xsl:for-each select="id">
				<hl:type>
					<hl:text>
						<xsl:value-of select="text()"/>
					</hl:text>
				</hl:type>
			</xsl:for-each>
		</hl:product>
	</xsl:template>

	<xsl:template match="enum/id" mode="decl">
		<hl:text>
			<xsl:value-of select="text()"/>
		</hl:text>
	</xsl:template>

	<xsl:template match="page">
		<hl:page><xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
			<xsl:apply-templates select="node()|text()"/>
		</hl:page>
	</xsl:template>

	<xsl:template match="pageattr">
		<hl:name>
			<hl:text>
				<xsl:value-of select="@name"/>
			</hl:text>
		</hl:name>
	</xsl:template>

	<xsl:template match="place">
		<hl:place><xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
			<xsl:apply-templates select="text"/>
			<xsl:apply-templates select="initmark"/>
			<xsl:apply-templates select="type"/>
			<hl:graphics>
				<xsl:apply-templates select="posattr|fillattr|lineattr" mode="graphics"/>
			</hl:graphics>
		</hl:place>
	</xsl:template>

	<xsl:template match="trans">
		<hl:transition><xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
			<xsl:apply-templates select="text"/>
			<xsl:apply-templates select="cond"/>
			<hl:toolspecific tool="CPN Tools" version="1.0.0">
				<xsl:apply-templates select="time"/>
				<xsl:apply-templates select="code"/>
			</hl:toolspecific>
			<hl:graphics>
				<xsl:apply-templates select="posattr|fillattr|lineattr" mode="graphics"/>
			</hl:graphics>
		</hl:transition>
	</xsl:template>

	<xsl:template name="arccommon">
		<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
		<xsl:apply-templates select="annot"/>
		<hl:graphics>
			<xsl:apply-templates select="lineattr" mode="graphics"/>
			<xsl:for-each select="bendpoint">
				<xsl:sort select="@serial" order="ascending" data-type="number"/>
				<xsl:apply-templates select="posattr" mode="graphics"/>
			</xsl:for-each>
		</hl:graphics>
	</xsl:template>

	<xsl:template match="arc[@orientation='PtoT']">
		<hl:arc>
			<xsl:attribute name="source"><xsl:value-of select="placeend/@idref"/></xsl:attribute>
			<xsl:attribute name="target"><xsl:value-of select="transend/@idref"/></xsl:attribute>
			<xsl:call-template name="arccommon"/>
			<hl:type><hl:text>normal</hl:text></hl:type>
		</hl:arc>
	</xsl:template>

	<xsl:template match="arc[@orientation='TtoP']">
		<hl:arc>
			<xsl:attribute name="source"><xsl:value-of select="transend/@idref"/></xsl:attribute>
			<xsl:attribute name="target"><xsl:value-of select="placeend/@idref"/></xsl:attribute>
			<xsl:call-template name="arccommon"/>
			<hl:type><hl:text>normal</hl:text></hl:type>
		</hl:arc>
	</xsl:template>

	<xsl:template match="arc[@orientation='BOTHDIR']">
		<hl:arc>
			<xsl:attribute name="source"><xsl:value-of select="transend/@idref"/></xsl:attribute>
			<xsl:attribute name="target"><xsl:value-of select="placeend/@idref"/></xsl:attribute>
			<xsl:call-template name="arccommon"/>
			<hl:type><hl:text>test</hl:text></hl:type>
		</hl:arc>
	</xsl:template>

	<xsl:template match="place/text|trans/text">
		<hl:name>
			<hl:text>
				<xsl:value-of select="text()"/>
			</hl:text>
		</hl:name>
	</xsl:template>

	<xsl:template match="initmark">
		<hl:initialMarking>
			<hl:text>
				<xsl:value-of select="text"/>
			</hl:text>
		</hl:initialMarking>
	</xsl:template>

	<xsl:template match="type">
		<hl:type>
			<hl:text>
				<xsl:value-of select="text"/>
			</hl:text>
		</hl:type>
	</xsl:template>

	<xsl:template match="cond">
		<hl:guard>
			<hl:text>
				<xsl:value-of select="text"/>
			</hl:text>
		</hl:guard>
	</xsl:template>

	<xsl:template match="time">
		<cpn:time>
			<cpn:text>
				<xsl:value-of select="text"/>
			</cpn:text>
		</cpn:time>
	</xsl:template>

	<xsl:template match="code">
		<cpn:code>
			<cpn:text>
				<xsl:value-of select="text"/>
			</cpn:text>
		</cpn:code>
	</xsl:template>

	<xsl:template match="annot">
		<hl:inscription>
			<hl:text>
				<xsl:value-of select="text"/>
			</hl:text>
		</hl:inscription>
	</xsl:template>

	<xsl:template match="posattr" mode="graphics">
		<hl:position>
			<xsl:attribute name="x"><xsl:value-of select="@x"/></xsl:attribute>
			<xsl:attribute name="y"><xsl:value-of select="@y"/></xsl:attribute>
		</hl:position>
	</xsl:template>

	<xsl:template match="fillattr" mode="graphics">
		<hl:fill>
			<xsl:attribute name="color">
				<xsl:call-template name="tolower">
					<xsl:with-param name="toconvert" select="@colour"/>
				</xsl:call-template>
			</xsl:attribute>
		</hl:fill>
	</xsl:template>

	<xsl:template match="lineattr" mode="graphics">
		<hl:line>
			<xsl:attribute name="color">
				<xsl:call-template name="tolower">
					<xsl:with-param name="toconvert" select="@colour"/>
				</xsl:call-template>
			</xsl:attribute>
			<xsl:attribute name="width">
				<xsl:value-of select="@thick"/>
			</xsl:attribute>
			<xsl:attribute name="style">solid</xsl:attribute>
		</hl:line>
		<hl:toolspecific tool="CPN Tools" version="1.0.0">
			<cpn:line>
				<xsl:attribute name="color">
					<xsl:call-template name="tolower">
						<xsl:with-param name="toconvert" select="@colour"/>
					</xsl:call-template>
				</xsl:attribute>
				<xsl:attribute name="width">
					<xsl:value-of select="@thick"/>
				</xsl:attribute>
				<xsl:attribute name="style">
					<xsl:call-template name="tolower">
						<xsl:with-param name="toconvert" select="@type"/>
					</xsl:call-template>
				</xsl:attribute>
			</cpn:line>
		</hl:toolspecific>
	</xsl:template>
</xsl:stylesheet>
