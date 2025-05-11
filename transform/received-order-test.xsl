<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
                xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
                xmlns:ord="http://www.stormware.cz/schema/version_2/order.xsd">
    <xsl:param name="year"/>
    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="lst:order[(ord:orderDetail)]">
        <objednavka-prijata>
            <bezPolozek>false</bezPolozek>
            <xsl:apply-templates select="ord:orderHeader"/>
            <xsl:apply-templates select="ord:orderDetail"/>
            <xsl:if test="ord:orderSummary/ord:foreignCurrency">
                <mena>code:<xsl:value-of
                  select="upper-case(ord:orderSummary/ord:foreignCurrency/typ:currency/typ:ids)"/>
                </mena>
                <kurz>
                    <xsl:value-of select="ord:foreignCurrency/typ:rate"/>
                </kurz>
            </xsl:if>
        </objednavka-prijata>
    </xsl:template>
    <!--    Případ, ve kterém objednávka neobsahuje detail, tudíž ani položky-->
    <xsl:template match="lst:invoice[not(ord:orderDetail)]">
        <objednavka-prijata>
            <bezPolozek>true</bezPolozek>
            <xsl:apply-templates select="ord:orderHeader"/>
            <xsl:apply-templates select="ord:orderSummary"/>
            <xsl:if test="ord:orderSummary/ord:foreignCurrency">
                <mena>code:<xsl:value-of
                  select="upper-case(ord:orderSummary/ord:foreignCurrency/typ:currency/typ:ids)"/>
                </mena>
                <kurz>
                    <xsl:value-of select="ord:foreignCurrency/typ:rate"/>
                </kurz>
            </xsl:if>
        </objednavka-prijata>
    </xsl:template>

    <xsl:template match="ord:orderHeader">
        <id>
            <xsl:value-of select="concat('ext:POHODA:', ord:id, '-', $year)"/>
        </id>
        <!--        Bez migrace číselných řad:-->
        <typDokl>code:OBP</typDokl>
        <!--        Při migraci číselných řad:-->
        <!--        <typDokl>code:PRIOBJ-131</typDokl>-->
        <zbyvaUhraditMen>0</zbyvaUhraditMen>
        <kod>
            <xsl:value-of select="ord:number/typ:numberRequested"/>
        </kod>
        <cisDosle>
            <xsl:choose>
                <!--                Received invoice shall use original document number -->
                <xsl:when test="ord:originalDocument">
                    <xsl:value-of select="ord:originalDocument"/>
                </xsl:when>
                <xsl:otherwise>
                    <!--                    If original document number is missing, use variable symbol instead-->
                    <xsl:value-of select="ord:symVar"/>
                </xsl:otherwise>
            </xsl:choose>
        </cisDosle>
        <varSym>
            <xsl:value-of select="ord:symVar"/>
        </varSym>
        <datVyst>
            <xsl:value-of select="ord:date"/>
        </datVyst>
        <datSazbyDph>
            <xsl:value-of select="ord:dateTax"/>
        </datSazbyDph>
        <datTermin>
            <xsl:value-of select="ord:dateDue"/>
        </datTermin>
        <datSplat>
            <xsl:value-of select="ord:dateDue"/>
        </datSplat>
        <popis>
            <xsl:value-of select="ord:text"/>
        </popis>
        <zaokrNaSumK>zaokrNa.zadne</zaokrNaSumK>
        <kontaktJmeno>
            <xsl:value-of select="ord:partnerIdentity/typ:address/typ:name"/>
        </kontaktJmeno>
        <kontaktEmail>
            <xsl:value-of select="ord:partnerIdentity/typ:address/typ:email"/>
        </kontaktEmail>
        <kontaktTel>
            <xsl:value-of select="ord:partnerIdentity/typ:address/typ:mobilPhone"/>
        </kontaktTel>
        <xsl:if test="ord:centre/typ:ids">
            <stredisko>
                <xsl:value-of select="concat('code:', upper-case(ord:centre/typ:ids))"/>
            </stredisko>
        </xsl:if>
        <xsl:if test="ord:activity/typ:ids">
            <cinnost>
                <xsl:value-of select="concat('code:', upper-case(ord:activity/typ:ids))"/>
            </cinnost>
        </xsl:if>
        <xsl:choose>
            <xsl:when
              test="ord:accounting/typ:ids and ord:accounting/typ:ids != 'Bez' and ord:accounting/typ:ids != 'Ručně'">
                <typUcOp evidencePath="predpis-zauctovani">
                    <xsl:value-of select="concat('ext:POHODA:', ord:accounting/typ:id, '-', $year)"/>
                </typUcOp>
                <kopTypUcOp>false</kopTypUcOp>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="ord:partnerIdentity/typ:id">
                <firma>
                    <xsl:value-of select="concat('ext:POHODA:', ord:partnerIdentity/typ:id, '-', $year)"/>
                </firma>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="adresaFirmy"/>
            </xsl:otherwise>
        </xsl:choose>
        <formaUhradyCis>
            <xsl:choose>
                <xsl:when test="ord:paymentType/typ:ids='Příkazem'">9</xsl:when>
                <xsl:when test="ord:paymentType/typ:ids='Hotově'">10</xsl:when>
                <xsl:otherwise>7</xsl:otherwise>
            </xsl:choose>
        </formaUhradyCis>
        <xsl:if test="ord:contract">
            <zakazka>code:<xsl:value-of select="upper-case(ord:contract/typ:ids)"/>
            </zakazka>
        </xsl:if>

    </xsl:template>
    <xsl:template match="ord:orderDetail">
        <polozkyObchDokladu>
            <xsl:apply-templates select="ord:orderItem"/>
        </polozkyObchDokladu>
    </xsl:template>

    <xsl:template match="ord:orderItem">
        <objednavka-prijata-polozka>
            <id>
                <xsl:value-of select="concat('ext:POHODA:', ord:id, '-', $year)"/>
            </id>
            <nazev>
                <xsl:value-of select="ord:text"/>
            </nazev>
            <!--                        <cenik>code:<xsl:value-of select="ord:code"/>-->
            <!--                        </cenik>-->
            <!--                        <sklad>code:01</sklad>-->
            <mnozMj>
                <xsl:value-of select="ord:quantity"/>
            </mnozMj>
            <xsl:if test="ord:unit">
                <mj>code:<xsl:value-of select="upper-case(ord:unit)"/>
                </mj>
            </xsl:if>
            <xsl:choose>
                <xsl:when
                  test="ord:accounting/typ:ids and ord:accounting/typ:ids != 'Bez' and ord:accounting/typ:ids != 'Ručně'">
                    <typUcOp evidencePath="predpis-zauctovani">
                        <xsl:value-of select="concat('ext:POHODA:', ord:accounting/typ:id, '-', $year)"/>
                    </typUcOp>
                    <kopTypUcOp>false</kopTypUcOp>
                </xsl:when>
                <xsl:otherwise>
                    <kopTypUcOp>true</kopTypUcOp>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="ord:contract">
                <zakazka>code:<xsl:value-of select="upper-case(ord:contract/typ:ids)"/>
                </zakazka>
            </xsl:if>

            <typPolozkyK>typPolozky.obecny</typPolozkyK>
            <typSazbyDph>
                <xsl:call-template name="typSazbaDph">
                    <xsl:with-param name="inputDph" select="ord:rateVAT"/>
                </xsl:call-template>
            </typSazbyDph>
            <szbDph>
                <xsl:value-of select="ord:rateVAT/@value"/>
            </szbDph>


            <!-- Takhle to asi má být, ale pro diamond nefunguje -->
            <!--                <xsl:choose>-->
            <!--                    <xsl:when test="ord:rateVAT = 'none'">-->
            <!--                        <typCenyDphK>typCeny.bezDph</typCenyDphK>-->
            <!--                        -->
            <!--                    </xsl:when>-->
            <!--                    <xsl:otherwise>-->
            <!--                        <typCenyDphK>typCeny.sDph</typCenyDphK>-->
            <!--                    </xsl:otherwise>-->
            <typCenyDphK>typCeny.bezDph</typCenyDphK>

            <xsl:choose>
                <xsl:when test="ord:foreignCurrency">
                    <cenaMj>
                        <xsl:value-of select="ord:foreignCurrency/typ:unitPrice"/>
                    </cenaMj>
                    <kurz>
                        <xsl:value-of select="ord:foreignCurrency/typ:rate"/>
                    </kurz>
                    <sumDph>
                        <xsl:value-of select="ord:foreignCurrency/typ:priceVAT"/>
                    </sumDph>
                </xsl:when>
                <xsl:otherwise>
                    <cenaMj>
                        <xsl:value-of select="ord:homeCurrency/typ:unitPrice"/>
                    </cenaMj>
                    <sumDph>
                        <xsl:value-of select="ord:homeCurrency/typ:priceVAT"/>
                    </sumDph>
                </xsl:otherwise>
            </xsl:choose>
            <slevaPol>
                <xsl:value-of select="ord:discountPercentage"/>
            </slevaPol>
            <xsl:if test="ord:centre/typ:ids">
                <stredisko>
                    <xsl:value-of select="concat('code:', upper-case(ord:centre/typ:ids))"/>
                </stredisko>
            </xsl:if>
            <xsl:if test="ord:activity/typ:ids">
                <cinnost>
                    <xsl:value-of select="concat('code:', upper-case(ord:activity/typ:ids))"/>
                </cinnost>
            </xsl:if>
        </objednavka-prijata-polozka>
    </xsl:template>

    <xsl:template match="ord:orderSummary">
        <xsl:choose>
            <xsl:when test="ord:foreignCurrency">
                <xsl:call-template name="summaryForeignCurrency"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="summaryHomeCurrency"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="typSazbaDph">
        <xsl:param name="inputDph"/>
        <xsl:choose>
            <xsl:when test="$inputDph = 'high'">typSzbDph.dphZakl</xsl:when>
            <xsl:when test="$inputDph = 'low'">typSzbDph.dphSniz</xsl:when>
            <xsl:when test="$inputDph = 'third'">typSzbDph.dphSniz2</xsl:when>
            <xsl:when test="$inputDph = 'none'">typSzbDph.dphOsv</xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="sazbaDph">
        <xsl:param name="inputDph"/>
        <xsl:choose>
            <xsl:when test="$inputDph = 'high'">21</xsl:when>
            <xsl:when test="$inputDph = 'low'">15</xsl:when>
            <xsl:when test="$inputDph = 'third'">10</xsl:when>
            <xsl:when test="$inputDph = 'none'">0</xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="adresaFirmy">
        <xsl:choose>
            <xsl:when test="ord:partnerIdentity/typ:address/typ:company">
                <nazFirmy>
                    <xsl:value-of select="ord:partnerIdentity/typ:address/typ:company"/>
                </nazFirmy>
            </xsl:when>
            <xsl:otherwise>
                <nazFirmy>
                    <xsl:value-of select="ord:partnerIdentity/typ:address/typ:name"/>
                </nazFirmy>
            </xsl:otherwise>
        </xsl:choose>
        <ulice>
            <xsl:value-of select="ord:partnerIdentity/typ:address/typ:street"/>
        </ulice>
        <mesto>
            <xsl:value-of select="ord:partnerIdentity/typ:address/typ:city"/>
        </mesto>
        <psc>
            <xsl:value-of select="ord:partnerIdentity/typ:address/typ:zip"/>
        </psc>
        <ic>
            <xsl:value-of select="ord:partnerIdentity/typ:address/typ:ico"/>
        </ic>
        <dic>
            <xsl:value-of select="ord:partnerIdentity/typ:address/typ:dic"/>
        </dic>
    </xsl:template>

    <xsl:template name="summaryForeignCurrency">
        <sumOsvMen>
            <xsl:value-of select="ord:foreignCurrency/typ:priceSum"/>
        </sumOsvMen>
    </xsl:template>

    <xsl:template name="summaryHomeCurrency">
        <sumZklZakl>
            <xsl:value-of select="ord:homeCurrency/typ:priceHigh"/>
        </sumZklZakl>
        <!--        <sumDphZakl>-->
        <!--            <xsl:value-of select="ord:homeCurrency/typ:priceHighVAT"/>-->
        <!--        </sumDphZakl>-->
        <!--        <sumDphSniz>-->
        <!--            <xsl:value-of select="ord:homeCurrency/typ:priceLowVAT"/>-->
        <!--        </sumDphSniz>-->
        <!--        <sumDphSniz2>-->
        <!--            <xsl:value-of select="ord:homeCurrency/typ:price3VAT"/>-->
        <!--        </sumDphSniz2>-->
        <sumOsv>
            <xsl:value-of select="ord:homeCurrency/typ:priceNone"/>
        </sumOsv>
        <sumCelkZakl>
            <xsl:value-of select="ord:homeCurrency/typ:priceHighSum"/>
        </sumCelkZakl>
        <sumCelkSniz>
            <xsl:value-of select="ord:homeCurrency/typ:priceLowSum"/>
        </sumCelkSniz>
        <sumCelkSniz2>
            <xsl:value-of select="ord:homeCurrency/typ:priceThirdSum"/>
        </sumCelkSniz2>
        <sumZklSniz2>
            <xsl:value-of select="ord:homeCurrency/typ:price3Sum"/>
        </sumZklSniz2>
        <sumZklSniz>
            <xsl:value-of select="ord:homeCurrency/typ:price2Sum"/>
        </sumZklSniz>
        <sumCelkem>
            <xsl:value-of select="ord:homeCurrency/typ:priceSum"/>
        </sumCelkem>
    </xsl:template>

</xsl:stylesheet>