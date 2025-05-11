<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:inf="http://www.dcos.cz/flexi-migration/invoice-functions"
    xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
    exclude-result-prefixes="xs" expand-text="yes" version="3.0">
    <xsl:function name="inf:invoice">
        <xsl:param name="vatRates"/>
        <xsl:param name="documentNumber"/>
        <xsl:param name="accountingId"/>
        <xsl:param name="docId"/>
        <xsl:param name="agendaType"/>
        <xsl:param name="journal_pohoda"/>
        <xsl:param name="agendaId"/>
        <xsl:param name="account-assignment_flexi"/>
        <xsl:variable name="account" select="
            document($journal_pohoda)/items/item[evidenceId
            = $agendaId and documentId = $docId
            and not(starts-with(text/text(), 'DPH'))][1]"/>
        <xsl:choose>
            <xsl:when test="$account and $account != ''">
                <xsl:choose>
                    <xsl:when test="$agendaType = 'PRIJEM'">
                        <!--                    Prijem ==>    PRIM UCET = DAL acc-->
                        <primUcet>code:{$account/dAccount}</primUcet>
                        <protiUcet>code:{$account/mdAccount}</protiUcet>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--             Vydej ==>        PRIM UCET = MD acc -->
                        <primUcet>code:{$account/mdAccount}</primUcet>
                        <protiUcet>code:{$account/dAccount}</protiUcet>
                    </xsl:otherwise>
                </xsl:choose>
                <!--        References the row in JOURNAL POHODA. Contains details about DPH account-->
                <xsl:variable name="vatAccount" select="
                        document($journal_pohoda)/items/item[evidenceId =
                        $agendaId and documentId = $docId and starts-with(text/text(), 'DPH')][1]"/>
                <xsl:choose>
                    <xsl:when test="$vatAccount and $vatAccount != ''">
                        <!--                         Pro vydej = DAL. Pro prijem = MD -->
                        <xsl:choose>
                            <xsl:when test="$agendaType = 'PRIJEM'">
                                <xsl:choose>
                                    <xsl:when test="contains($vatRates, '21')">
                                        <dphZaklUcet>code:{$vatAccount/mdAccount}</dphZaklUcet>
                                    </xsl:when>
                                    <xsl:when
                                        test="contains($vatRates, '15') or contains($vatRates, '12')">
                                        <dphSnizUcet>code:{$vatAccount/mdAccount}</dphSnizUcet>
                                    </xsl:when>
                                    <xsl:when test="contains($vatRates, '10')">
                                        <dphSniz2Ucet>code:{$vatAccount/mdAccount}</dphSniz2Ucet>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="contains($vatRates, '21')">
                                        <dphZaklUcet>code:{$vatAccount/dAccount}</dphZaklUcet>
                                    </xsl:when>
                                    <xsl:when
                                        test="contains($vatRates, '15') or contains($vatRates, '12')">
                                        <dphSnizUcet>code:{$vatAccount/dAccount}</dphSnizUcet>
                                    </xsl:when>
                                    <xsl:when test="contains($vatRates, '10')">
                                        <dphSniz2Ucet>code:{$vatAccount/dAccount}</dphSniz2Ucet>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="$vatRates != '' and number($vatRates) > 0">
                            <xsl:message>ACC_PROBLEM: Záučtovaní DPH dokladu neproběhlo. Nenalezen
                                záznam v účetním deníku pro dokument s id <xsl:value-of
                                    select="$docId"/>, číslo dokumentu:<xsl:value-of
                                    select="$documentNumber"/>
                            </xsl:message>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>

                <xsl:variable name="accountAssignment" as="node()*">
                    <xsl:sequence
                        select="document($account-assignment_flexi)/winstrom/predpis-zauctovani[id = $accountingId]"
                    />
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$accountAssignment and not(string($accountAssignment) = '')">
                        <xsl:choose>
                            <xsl:when test="$agendaType = 'VYDEJ'">
                                <protiUcet>
                                    <xsl:sequence select="$accountAssignment/protiUcetVydej/text()"
                                    />
                                </protiUcet>
                                <primUcet>
                                    <xsl:sequence select="$accountAssignment/protiUcetPrijem/text()"
                                    />
                                </primUcet>
                            </xsl:when>
                            <xsl:otherwise>
                                <protiUcet>
                                    <!--                                    DAL ucet-->
                                    <xsl:sequence select="$accountAssignment/protiUcetPrijem/text()"
                                    />
                                </protiUcet>
                                <primUcet>
                                    <!--                                    MD ucet-->
                                    <xsl:sequence select="$accountAssignment/protiUcetVydej/text()"
                                    />
                                </primUcet>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>ACC_PROBLEM: Záučtovaní dokladu neproběhlo. Nenalezen záznam v
                            předkontacích pro dokument s id <xsl:value-of select="$docId"/>, číslo
                                dokumentu:<xsl:value-of select="$documentNumber"/>. ID předkontace:
                                <xsl:value-of select="$accountingId"/>
                        </xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="inf:invoiceItem">
        <xsl:param name="documentNumber"/>
        <xsl:param name="docId"/>
        <xsl:param name="itemNode"/>
        <xsl:param name="agendaType"/>
        <xsl:param name="journal_pohoda"/>
        <xsl:param name="agendaId"/>
        <xsl:variable name="price">
            <xsl:sequence select="$itemNode/*:homeCurrency/typ:price"/>
        </xsl:variable>
        <xsl:variable name="priceVat">
            <xsl:sequence select="$itemNode/*:homeCurrency/typ:priceVAT"/>
        </xsl:variable>
        <xsl:variable name="account" select="
            document($journal_pohoda)/items/item[evidenceId = $agendaId and documentId
            = $docId and not(starts-with(text/text(), 'DPH'))
            and abs(xs:decimal(amount)) = abs(xs:decimal($price))][1]"/>
        <xsl:choose>
            <xsl:when test="$account and $account != ''">

                <xsl:if test="$agendaType = 'PRIJEM' or 'BOTH'">
                    <kopZklMdUcet>false</kopZklMdUcet>
                    <!--                    MD account-->
                    <zklMdUcet>
                        <xsl:sequence select="'code' || $account/mdAccount"/>
                    </zklMdUcet>
                </xsl:if>
                <xsl:if test="$agendaType = 'VYDEJ' or 'BOTH'">
                    <kopZklDalUcet>false</kopZklDalUcet>
                    <!--                    DAL account-->
                    <zklDalUcet>
                        <xsl:sequence select="'code:' || $account/dAccount"/>
                    </zklDalUcet>
                </xsl:if>
                <xsl:variable name="vatAccount" select="
                        document($journal_pohoda)/items/item[evidenceId = $agendaId and documentId
                        = $docId and starts-with(text/text(), 'DPH')
                        and abs(xs:decimal(amount)) = abs(xs:decimal($priceVat))][1]"/>
                <xsl:choose>
                    <xsl:when test="$vatAccount and $vatAccount != ''">
                        <xsl:if test="$agendaType = 'PRIJEM' or 'BOTH'">
                            <kopDphMdUcet>false</kopDphMdUcet>
                            <dphMdUcet>
                                <xsl:sequence select="'code:' || $vatAccount/mdAccount"/>
                            </dphMdUcet>
                        </xsl:if>

                        <xsl:if test="$agendaType = 'VYDEJ' or 'BOTH'">
                            <kopDphDalUcet>false</kopDphDalUcet>
                            <dphDalUcet>
                                <xsl:sequence select="'code:' || $vatAccount/dAccount"/>
                            </dphDalUcet>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="number($priceVat) > 0">
                            <xsl:message>ACC_PROBLEM: Záučtovaní DPH dokladu neproběhlo. Nenalezen
                                záznam v účetním deníku pro dokument s id <xsl:value-of
                                    select="$docId"/>, číslo dokumentu:<xsl:value-of
                                    select="$documentNumber"/>
                            </xsl:message>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="inf:invoiceById">
        <xsl:param name="accountingId"/>
        <xsl:param name="account-assignment_flexi"/>
        <xsl:param name="agendaType"/>
        <xsl:variable name="accountAssignment" as="node()*">
            <xsl:sequence
                select="document($account-assignment_flexi)/winstrom/predpis-zauctovani[id = $accountingId]"
            />
        </xsl:variable>
        <xsl:if test="$accountAssignment and not(string($accountAssignment) = '')">
            <xsl:choose>
                <xsl:when test="$agendaType = 'VYDEJ'">
                    <protiUcet>
                        <xsl:sequence select="$accountAssignment/protiUcetVydej/text()"/>
                    </protiUcet>
                    <primUcet>
                        <xsl:sequence select="$accountAssignment/protiUcetPrijem/text()"/>
                    </primUcet>
                </xsl:when>
                <xsl:otherwise>
                    <protiUcet>
                        <xsl:sequence select="$accountAssignment/protiUcetPrijem/text()"/>
                    </protiUcet>
                    <primUcet>
                        <xsl:sequence select="$accountAssignment/protiUcetVydej/text()"/>
                    </primUcet>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>
</xsl:stylesheet>
