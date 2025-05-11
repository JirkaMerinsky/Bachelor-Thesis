<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:f="http://www.dcos.cz/flexi-migration/functions">

    <xsl:import href="general/functions.xsl"/>
    <xsl:import href="general/variables.xsl"/>
    <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"/>

    <xsl:param name="issued-invoice_flexi"/>
    <xsl:param name="received-invoice_flexi"/>
    <xsl:param name="other-debt_flexi"/>
    <xsl:param name="other-obligation_flexi"/>
    <xsl:param name="internal-document_flexi"/>

    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="Uhrady">
        <xsl:variable name="payment_id" select="ID"/>
        <xsl:variable name="paid_document_id" select="concat('ext:POHODA:', RelIDH)"/>
        <xsl:variable name="paid_document_evidence" select="RelAgH"/>
        <xsl:variable name="payment_document_id" select="concat('ext:POHODA:', RelIDU)"/>
        <xsl:variable name="payment_document_amount" select="CmU"/>
        <xsl:variable name="payment_document_evidence" select="RelAgU"/>

        <xsl:if test="not($payment_document_evidence = 27 or $payment_document_evidence = 28)">
            <xsl:choose>
                <!-- issued-invoice -->
                <xsl:when test="$paid_document_evidence = 2">
                    <xsl:for-each select="document($issued-invoice_flexi)/winstrom/faktura-vydana">
                        <xsl:if test="id = $paid_document_id and not($payment_document_id = 'ext:POHODA:')">
                            <xsl:sequence
                              select="f:pair_node($payment_id, $paid_document_id, $paid_document_evidence, $payment_document_id, $payment_document_amount, $payment_document_evidence)"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <!-- received-invoice -->
                <xsl:when test="$paid_document_evidence = 3">
                    <xsl:for-each select="document($received-invoice_flexi)/winstrom/faktura-prijata">
                        <xsl:if test="id = $paid_document_id and not($payment_document_id = 'ext:POHODA:')">
                            <xsl:sequence
                              select="f:pair_node($payment_id, $paid_document_id, $paid_document_evidence, $payment_document_id, $payment_document_amount, $payment_document_evidence)"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <!-- other-debt -->
                <xsl:when test="$paid_document_evidence = 18">
                    <xsl:for-each select="document($other-debt_flexi)/winstrom/pohledavka">
                        <xsl:if test="id = $paid_document_id and not($payment_document_id = 'ext:POHODA:')">
                            <xsl:sequence
                              select="f:pair_node($payment_id, $paid_document_id, $paid_document_evidence, $payment_document_id, $payment_document_amount, $payment_document_evidence)"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <!-- other-obligation -->
                <xsl:when test="$paid_document_evidence = 19">
                    <xsl:for-each select="document($other-obligation_flexi)/winstrom/zavazek">
                        <xsl:if test="id = $paid_document_id and not($payment_document_id = 'ext:POHODA:')">
                            <xsl:sequence
                              select="f:pair_node($payment_id, $paid_document_id, $paid_document_evidence, $payment_document_id, $payment_document_amount, $payment_document_evidence)"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <!-- internal-document -->
                <xsl:when test="$paid_document_evidence = 29">
                    <xsl:for-each select="document($internal-document_flexi)/winstrom/interni-doklad">
                        <xsl:if test="id = $paid_document_id and not($payment_document_id = 'ext:POHODA:')">
                            <xsl:sequence
                              select="f:pair_node($payment_id, $paid_document_id, $paid_document_evidence, $payment_document_id, $payment_document_amount, $payment_document_evidence)"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:function name="f:pair_node">
        <xsl:param name="payment_id"/>
        <xsl:param name="paid_document_id"/>
        <xsl:param name="paid_document_evidence"/>
        <xsl:param name="payment_document_id"/>
        <xsl:param name="payment_document_amount"/>
        <xsl:param name="payment_document_evidence"/>

        <xsl:variable name="payment_document_evidence_tag">
            <xsl:choose>
                <xsl:when test="$payment_document_evidence = 2">faktura-vydana</xsl:when>
                <xsl:when test="$payment_document_evidence = 3">faktura-prijata</xsl:when>
                <xsl:when test="$payment_document_evidence = 18">pohledavka</xsl:when>
                <xsl:when test="$payment_document_evidence = 19">zavazek</xsl:when>
                <xsl:when test="$payment_document_evidence = 29">pohledavka</xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="paid_document_evidence_tag">
            <xsl:choose>
                <xsl:when test="$paid_document_evidence = 2">faktura-vydana</xsl:when>
                <xsl:when test="$paid_document_evidence = 3">faktura-prijata</xsl:when>
                <xsl:when test="$paid_document_evidence = 18">pohledavka</xsl:when>
                <xsl:when test="$paid_document_evidence = 19">zavazek</xsl:when>
                <xsl:when test="$paid_document_evidence = 29">zavazek</xsl:when>
            </xsl:choose>
        </xsl:variable>

        <pokladni-pohyb>
            <id>ext:POHODA:<xsl:value-of select="$payment_id"/>1
            </id>
            <sumOsv>
                <xsl:value-of select="$payment_document_amount"/>
            </sumOsv>
            <!-- TODO: multiple currencies -->
            <mena>code:CZK</mena>
            <pokladna>code:POKLADNA KČ</pokladna>
            <typDokl>code:POHODA-CZK</typDokl>
            <typPohybuK>typPohybu.prijem</typPohybuK>
            <bezPolozek>true</bezPolozek>
            <sparovani>
                <uhrazovanaFak>
                    <xsl:attribute name="type" select="$payment_document_evidence_tag"/>
                    <xsl:attribute name="castka" select="$payment_document_amount"/>
                    <xsl:value-of select="$payment_document_id"/>
                </uhrazovanaFak>
                <zbytek>castecnaUhradaNeboIgnorovat</zbytek>
            </sparovani>
        </pokladni-pohyb>
        <pokladni-pohyb>
            <id>ext:POHODA:<xsl:value-of select="$payment_id"/>2
            </id>
            <sumOsv>
                <xsl:value-of select="$payment_document_amount"/>
            </sumOsv>
            <!-- TODO: multiple currencies -->
            <mena>code:CZK</mena>
            <pokladna>code:POKLADNA KČ</pokladna>
            <typDokl>code:POHODA-CZK</typDokl>
            <typPohybuK>typPohybu.vydej</typPohybuK>
            <bezPolozek>true</bezPolozek>
            <sparovani>
                <uhrazovanaFak>
                    <xsl:attribute name="type" select="$paid_document_evidence_tag"/>
                    <xsl:attribute name="castka" select="$payment_document_amount"/>
                    <xsl:value-of select="$paid_document_id"/>
                </uhrazovanaFak>
                <zbytek>castecnaUhradaNeboIgnorovat</zbytek>
            </sparovani>
        </pokladni-pohyb>

    </xsl:function>

</xsl:stylesheet>