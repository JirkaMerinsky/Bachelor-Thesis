<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:json="http://json.org/" xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
    xmlns:con="http://www.stormware.cz/schema/version_2/contract.xsd"
    xmlns:lCon="http://www.stormware.cz/schema/version_2/list_contract.xsd"
    xmlns:gi="http://www.dcos.cz/flexi-migration/functions" expand-text="yes">
    <xsl:include href="general/generate-id.xsl"/>
    <xsl:param name="year"/>
    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="lCon:contract/con:contractDesc">
        <zakazka>
            <id>{gi:generateId(con:id, $year, true(), false())}</id>
            <kod>{con:number/typ:numberRequested}</kod>
            <nazev>{con:text}</nazev>
            <datZahaj>{con:dateStart}</datZahaj>
            <datKonec>{con:dateDelivery}</datKonec>

            <datZahajPlan>{con:datePlanStart}</datZahajPlan>
            <datPredaniPlan>{con:datePlanDelivery}</datPredaniPlan>

            <xsl:if test="con:partnerIdentity/typ:id">
                <firma>ext:POHODA:{con:partnerIdentity/typ:id}</firma>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="con:contractState = 'planned'">
                    <stavZakazky>code:ZÍSKÁVÁME</stavZakazky>
                </xsl:when>
                <xsl:otherwise>
                    <stavZakazky>code:MÁME</stavZakazky>
                </xsl:otherwise>
            </xsl:choose>

            <poznam>{con:note}</poznam>
            <!-- TODO: -->
            <typZakazky showAs="NEVÝROBNÍ: Nevýrobní typ zakázky">code:NEVÝROBNÍ</typZakazky>
        </zakazka>
    </xsl:template>

</xsl:stylesheet>
