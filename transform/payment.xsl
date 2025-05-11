<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:json="http://json.org/" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="http://www.dcos.cz/flexi-migration/functions"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map">

    <xsl:import href="general/functions.xsl"/>
    <xsl:import href="general/variables.xsl"/>
    <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"/>

    <xsl:param name="issued-invoice_flexi"/>
    <xsl:param name="received-invoice_flexi"/>
    <xsl:param name="other-debt_flexi"/>
    <xsl:param name="other-obligation_flexi"/>
    <xsl:param name="internal-document_flexi"/>
    <xsl:param name="year"/>

    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="Uhrady">
        <xsl:variable name="paid_document_id" select="concat('ext:POHODA:', RelIDH, '-', $year)"/>
        <xsl:variable name="paid_document_num" select="concat('ext:POHODA:', CisloH)"/>
        <xsl:variable name="paid_document_evidence" select="RelAgH"/>
        <xsl:variable name="payment_document_id" select="concat('ext:POHODA:', RelIDU, '-', $year)"/>
        <xsl:variable name="payment_document_num" select="concat('ext:POHODA:', CisloU)"/>
        <xsl:variable name="payment_document_amount" select="CmU"/>
        <xsl:variable name="payment_document_evidence" select="RelAgU"/>

        <xsl:if test="$payment_document_evidence = 27 or $payment_document_evidence = 28">
            <xsl:choose>
                <!-- issued-invoice -->
                <xsl:when test="$paid_document_evidence = 2">
                    <xsl:for-each select="document($issued-invoice_flexi)/winstrom/faktura-vydana">
                        <xsl:if
                            test="id = $paid_document_num and not($payment_document_id = concat('ext:POHODA:-', $year))">
                            <xsl:sequence
                                select="f:pair_node($paid_document_id, $paid_document_num, $paid_document_evidence, $payment_document_id, $payment_document_num, $payment_document_amount, $payment_document_evidence)"
                            />
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <!-- received-invoice -->
                <xsl:when test="$paid_document_evidence = 3">
                    <xsl:for-each
                        select="document($received-invoice_flexi)/winstrom/faktura-prijata">
                        <xsl:if
                            test="id = $paid_document_num and not($payment_document_id = concat('ext:POHODA:-', $year))">
                            <xsl:sequence
                                select="f:pair_node($paid_document_id, $paid_document_num, $paid_document_evidence, $payment_document_id, $payment_document_num, $payment_document_amount, $payment_document_evidence)"
                            />
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <!-- other-debt -->
                <xsl:when test="$paid_document_evidence = 18">
                    <xsl:for-each select="document($other-debt_flexi)/winstrom/pohledavka">
                        <xsl:if
                            test="id = $paid_document_num and not($payment_document_id = concat('ext:POHODA:-', $year))">
                            <xsl:sequence
                                select="f:pair_node($paid_document_id, $paid_document_num, $paid_document_evidence, $payment_document_id, $payment_document_num, $payment_document_amount, $payment_document_evidence)"
                            />
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <!-- other-obligation -->
                <xsl:when test="$paid_document_evidence = 19">
                    <xsl:for-each select="document($other-obligation_flexi)/winstrom/zavazek">
                        <xsl:if
                            test="id = $paid_document_num and not($payment_document_id = concat('ext:POHODA:-', $year))">
                            <xsl:sequence
                                select="f:pair_node($paid_document_id, $paid_document_num, $paid_document_evidence, $payment_document_id, $payment_document_num, $payment_document_amount, $payment_document_evidence)"
                            />
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
            </xsl:choose>
        </xsl:if>


        <xsl:if
            test="$payment_document_id = concat('ext:POHODA:-', $year) and $payment_document_evidence = 0">

            <xsl:variable name="paid_document_evidence_tag" as="xs:string?">
                <xsl:sequence select="
                    map {
                    '2': 'faktura-vydana',
                    '3': 'faktura-prijata',
                    '18': 'pohledavka',
                    '19': 'zavazek'
                    } => map:get(string($paid_document_evidence))"/>
            </xsl:variable>

            <xsl:if test="$paid_document_evidence_tag and $paid_document_evidence_tag != ''">
                <xsl:element name="{$paid_document_evidence_tag}">
                    <xsl:attribute name="json:force-array" select="'true'"/>
                    <id>
                        <xsl:value-of select="$paid_document_num"/>
                    </id>
                </xsl:element>
            </xsl:if>
        </xsl:if>

    </xsl:template>

    <xsl:function name="f:pair_node">
        <xsl:param name="paid_document_id"/>
        <xsl:param name="paid_document_num"/>
        <xsl:param name="paid_document_evidence"/>
        <xsl:param name="payment_document_id"/>
        <xsl:param name="payment_document_num"/>
        <xsl:param name="payment_document_amount"/>
        <xsl:param name="payment_document_evidence"/>

        <xsl:variable name="payment_document_evidence_tag" as="xs:string?">
            <xsl:sequence select="
                    if ($payment_document_evidence = 27) then
                        'pokladni-pohyb'
                    else
                        if ($payment_document_evidence = 28) then
                            'banka'
                        else
                            ()
                    "/>
        </xsl:variable>
        <xsl:variable name="paid_document_evidence_tag" as="xs:string?">
            <xsl:sequence select="
                    map {
                        '2': 'faktura-vydana',
                        '3': 'faktura-prijata',
                        '18': 'pohledavka',
                        '19': 'zavazek'
                    } => map:get(string($paid_document_evidence))"/>
        </xsl:variable>



        <xsl:variable name="correct_amount">
            <xsl:choose>
                <xsl:when test="xs:decimal($payment_document_amount) lt 0">
                    <xsl:value-of select="$payment_document_amount * (-1)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$payment_document_amount"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:element name="{$payment_document_evidence_tag}">
            <xsl:attribute name="json:force-array" select="'true'"/>
            <id>
                <xsl:value-of select="$payment_document_id"/>
            </id>
            <sparovani>
                <uhrazovanaFak>
                    <xsl:attribute name="type" select="$paid_document_evidence_tag"/>
                    <xsl:attribute name="castka" select="$correct_amount"/>
                    <xsl:value-of select="$paid_document_num"/>
                </uhrazovanaFak>
                <zbytek>castecnaUhradaNeboIgnorovat</zbytek>
            </sparovani>
        </xsl:element>
    </xsl:function>

</xsl:stylesheet>
