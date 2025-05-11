<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:rsp="http://www.stormware.cz/schema/version_2/response.xsd"
                xmlns:rdc="http://www.stormware.cz/schema/version_2/documentresponse.xsd"
                xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
                xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
                xmlns:lStk="http://www.stormware.cz/schema/version_2/list_stock.xsd"
                xmlns:lAdb="http://www.stormware.cz/schema/version_2/list_addBook.xsd"
                xmlns:lCen="http://www.stormware.cz/schema/version_2/list_centre.xsd"
                xmlns:lAcv="http://www.stormware.cz/schema/version_2/list_activity.xsd"
                xmlns:acu="http://www.stormware.cz/schema/version_2/accountingunit.xsd"
                xmlns:inv="http://www.stormware.cz/schema/version_2/invoice.xsd"
                xmlns:vch="http://www.stormware.cz/schema/version_2/voucher.xsd"
                xmlns:int="http://www.stormware.cz/schema/version_2/intDoc.xsd"
                xmlns:stk="http://www.stormware.cz/schema/version_2/stock.xsd"
                xmlns:ord="http://www.stormware.cz/schema/version_2/order.xsd"
                xmlns:ofr="http://www.stormware.cz/schema/version_2/offer.xsd"
                xmlns:enq="http://www.stormware.cz/schema/version_2/enquiry.xsd"
                xmlns:vyd="http://www.stormware.cz/schema/version_2/vydejka.xsd"
                xmlns:pri="http://www.stormware.cz/schema/version_2/prijemka.xsd"
                xmlns:bal="http://www.stormware.cz/schema/version_2/balance.xsd"
                xmlns:pre="http://www.stormware.cz/schema/version_2/prevodka.xsd"
                xmlns:vyr="http://www.stormware.cz/schema/version_2/vyroba.xsd"
                xmlns:pro="http://www.stormware.cz/schema/version_2/prodejka.xsd"
                xmlns:con="http://www.stormware.cz/schema/version_2/contract.xsd"
                xmlns:adb="http://www.stormware.cz/schema/version_2/addressbook.xsd"
                xmlns:prm="http://www.stormware.cz/schema/version_2/parameter.xsd"
                xmlns:lCon="http://www.stormware.cz/schema/version_2/list_contract.xsd"
                xmlns:ctg="http://www.stormware.cz/schema/version_2/category.xsd"
                xmlns:ipm="http://www.stormware.cz/schema/version_2/intParam.xsd"
                xmlns:str="http://www.stormware.cz/schema/version_2/storage.xsd"
                xmlns:idp="http://www.stormware.cz/schema/version_2/individualPrice.xsd"
                xmlns:sup="http://www.stormware.cz/schema/version_2/supplier.xsd"
                xmlns:prn="http://www.stormware.cz/schema/version_2/print.xsd"
                xmlns:lck="http://www.stormware.cz/schema/version_2/lock.xsd"
                xmlns:isd="http://www.stormware.cz/schema/version_2/isdoc.xsd"
                xmlns:sEET="http://www.stormware.cz/schema/version_2/sendEET.xsd"
                xmlns:act="http://www.stormware.cz/schema/version_2/accountancy.xsd"
                xmlns:bnk="http://www.stormware.cz/schema/version_2/bank.xsd"
                xmlns:sto="http://www.stormware.cz/schema/version_2/store.xsd"
                xmlns:grs="http://www.stormware.cz/schema/version_2/groupStocks.xsd"
                xmlns:acp="http://www.stormware.cz/schema/version_2/actionPrice.xsd"
                xmlns:csh="http://www.stormware.cz/schema/version_2/cashRegister.xsd"
                xmlns:bka="http://www.stormware.cz/schema/version_2/bankAccount.xsd"
                xmlns:ilt="http://www.stormware.cz/schema/version_2/inventoryLists.xsd"
                xmlns:nms="http://www.stormware.cz/schema/version_2/numericalSeries.xsd"
                xmlns:pay="http://www.stormware.cz/schema/version_2/payment.xsd"
                xmlns:mKasa="http://www.stormware.cz/schema/version_2/mKasa.xsd"
                xmlns:gdp="http://www.stormware.cz/schema/version_2/GDPR.xsd"
                xmlns:est="http://www.stormware.cz/schema/version_2/establishment.xsd"
                xmlns:cen="http://www.stormware.cz/schema/version_2/centre.xsd"
                xmlns:acv="http://www.stormware.cz/schema/version_2/activity.xsd"
                xmlns:afp="http://www.stormware.cz/schema/version_2/accountingFormOfPayment.xsd"
                xmlns:vat="http://www.stormware.cz/schema/version_2/classificationVAT.xsd"
                xmlns:rgn="http://www.stormware.cz/schema/version_2/registrationNumber.xsd"
                xmlns:ftr="http://www.stormware.cz/schema/version_2/filter.xsd"
                xmlns:asv="http://www.stormware.cz/schema/version_2/accountingSalesVouchers.xsd"
                xmlns:arch="http://www.stormware.cz/schema/version_2/archive.xsd"
                xmlns:req="http://www.stormware.cz/schema/version_2/productRequirement.xsd"
                xmlns:mov="http://www.stormware.cz/schema/version_2/movement.xsd"
                xmlns:rec="http://www.stormware.cz/schema/version_2/recyclingContrib.xsd"
                xmlns:srv="http://www.stormware.cz/schema/version_2/service.xsd"
                xmlns:rul="http://www.stormware.cz/schema/version_2/rulesPairing.xsd"
                xmlns:lwl="http://www.stormware.cz/schema/version_2/liquidationWithoutLink.xsd"
                xmlns:dis="http://www.stormware.cz/schema/version_2/discount.xsd"
                xmlns:lqd="http://www.stormware.cz/schema/version_2/automaticLiquidation.xsd"
                exclude-result-prefixes="xs rsp rdc typ lst lStk lAdb lCen lAcv acu inv vch int stk ord ofr enq vyd
                pri bal pre vyr pro con adb prm lCon ctg ipm str idp sup prn lck isd sEET act bnk sto grs acp csh
                bka ilt nms pay mKasa gdp est cen acv afp vat rgn ftr asv arch req mov rec srv rul lwl dis lqd">
    <xsl:strip-space elements="*"/>
    <xsl:template match="/">
        <items>
            <xsl:apply-templates/>
        </items>
    </xsl:template>
    <xsl:template name="item"
                  match="rsp:responsePackItem/lst:listClassificationVAT/lst:classificationVAT/vat:classificationVATHeader">
        <xsl:if test="not(vat:lineInVATReturn = '---')">
            <item>
                <Pohoda_zkratka>
                    <xsl:value-of select="vat:code"/>
                </Pohoda_zkratka>
                <Flexi_radky_dph_zkratka>
                    <xsl:choose>
                        <xsl:when test="vat:name = 'Dovoz zboží'">
                            <xsl:text>07-08</xsl:text>
                        </xsl:when>
                        <xsl:when test="vat:name = 'Tuzemské plnění'">
                            <xsl:text>01-02</xsl:text>
                        </xsl:when>
                        <xsl:when
                          test="vat:name = 'Zaslání zboží z jiného státu s plněním v tuzemsku'">
                            <xsl:text>01-02 EU-N</xsl:text>
                        </xsl:when>
                        <xsl:when test="vat:code = 'UK' or vat:code = 'UKA4' or vat:code = 'UKA5'">
                            <xsl:text>01-02, 51 SN</xsl:text>
                        </xsl:when>
                        <xsl:when test="matches(vat:lineInVATReturn, '^2[0-6], 51$')">
                            <xsl:value-of
                              select="concat('2', substring(vat:lineInVATReturn, 2, 1), ', 51 SN')"
                            />
                        </xsl:when>
                        <xsl:when test="vat:lineInVATReturn = '40, 41, 47'">
                            <xsl:text>47</xsl:text>
                        </xsl:when>
                        <xsl:when test="vat:lineInVATReturn = '43, 44, 47'">
                            <xsl:text>47</xsl:text>
                        </xsl:when>
                        <xsl:when test="vat:lineInVATReturn = '50, 51'">
                            <xsl:text>50, 51 BN</xsl:text>
                        </xsl:when>
                        <xsl:when test="vat:lineInVATReturn = '33, 1, 2'">
                            <xsl:text>33</xsl:text>
                        </xsl:when>
                        <xsl:when test="vat:lineInVATReturn = '34, 40, 41'">
                            <xsl:text>34</xsl:text>
                        </xsl:when>
                        <xsl:when test="vat:lineInVATReturn = '42, 47'">
                            <xsl:text>42, 47</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="matches(vat:lineInVATReturn, '^\d{2}, \d{2}$')">
                                <xsl:value-of select="
                                        concat(substring-before(vat:lineInVATReturn,
                                        ','), '-', substring-after(vat:lineInVATReturn, ' '))"
                                />
                            </xsl:if>
                            <xsl:if test="matches(vat:lineInVATReturn, '^\d{2}$')">
                                <xsl:value-of select="vat:lineInVATReturn"/>
                            </xsl:if>
                            <xsl:if test="matches(vat:lineInVATReturn, '^\d{1}$')">
                                <xsl:value-of select="concat('0', vat:lineInVATReturn)"/>
                            </xsl:if>
                            <xsl:if test="matches(vat:lineInVATReturn, '^\d{1}, \d{1}$')">
                                <xsl:value-of select="
                                        concat('0',
                                        substring-before(vat:lineInVATReturn, ','), '-', '0',
                                        substring-after(vat:lineInVATReturn, ' '))"
                                />
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!--                <xsl:value-of select="vat:lineInVATReturn"/>-->
                </Flexi_radky_dph_zkratka>
                <Flexi_radky_khdph_zkratka>
                    <xsl:choose>
                        <xsl:when test="vat:sectionInVATLedgerStatement = 'A.4., A.5.'">
                            <xsl:text>A.4-5.AUTO</xsl:text>
                        </xsl:when>
                        <xsl:when test="vat:sectionInVATLedgerStatement = 'A.4.'">
                            <xsl:text>A.4.-0</xsl:text>
                        </xsl:when>
                        <xsl:when test="vat:sectionInVATLedgerStatement = 'B.2., B.3.'">
                            <xsl:text>B.2-3.AUTO</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when
                                  test="matches(vat:sectionInVATLedgerStatement, '^[A-Z]\.\d\.$')">
                                    <xsl:value-of select="vat:sectionInVATLedgerStatement"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>0.0.</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </Flexi_radky_khdph_zkratka>
            </item>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
