<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="majetek">
        <majetek>
            <kod>
                <xsl:value-of select="Číslo"/>
            </kod>
            <nazev>
                <xsl:value-of select="Název"/>
            </nazev>
            <cena>
                <xsl:value-of
                  select="concat(substring-before(Účetní_pořizovací_cena, ','), '.', substring-before(substring-after(Účetní_pořizovací_cena, ','), ' '))"/>
            </cena>
            <zustUcet>
                <xsl:value-of
                  select="concat(substring-before(Účetní_zůstatek, ','), '.', substring-before(substring-after(Účetní_zůstatek, ','), ' '))"/>
            </zustUcet>
            <zustDan>
                <xsl:value-of
                  select="concat(substring-before(Daňový_zůstatek, ','), '.', substring-before(substring-after(Daňový_zůstatek, ','), ' '))"/>
            </zustDan>

            <zpusPor>
                <xsl:value-of select="Způsob_pořízení"/>
            </zpusPor>
            <datKoupe>
                <xsl:call-template name="changeDateFormat">
                    <xsl:with-param name="inputDate" select="Pořízení"/>
                </xsl:call-template>
            </datKoupe>
            <datZar>
                <xsl:call-template name="changeDateFormat">
                    <xsl:with-param name="inputDate" select="Zařazení"/>
                </xsl:call-template>
            </datZar>

            <typMajetku>
                <xsl:choose>
                    <xsl:when test="Typ = 'HM' and Způsob != 'Neodpisovat'">code:DLOUHODOBÝ HM.</xsl:when>
                    <xsl:otherwise>code:NEODEPISOVANÝ</xsl:otherwise>
                </xsl:choose>
            </typMajetku>


            <uctovatZar>true</uctovatZar>
            <datUdalVyr>
                <xsl:if test="Vyřazení !=''">
                    <xsl:call-template name="changeDateFormat">
                        <xsl:with-param name="inputDate" select="Vyřazení"/>
                    </xsl:call-template>
                </xsl:if>
            </datUdalVyr>

            <poznam>
                <xsl:value-of select="Poznámka"/>
            </poznam>
            <xsl:choose>
                <xsl:when test="Plán = '4R' and Účetní_zůstatek !='0,00 Kč'">
                    <xsl:call-template name="odpisovanyMajetek"/>
                </xsl:when>
                <xsl:otherwise>
                    <druhK>druhMaj.neodepis</druhK>
                </xsl:otherwise>
            </xsl:choose>

        </majetek>

    </xsl:template>

    <xsl:template name="odpisovanyMajetek">
        <druhK>druhMaj.hmDl</druhK>
        <zpusOdpK>
            <xsl:choose>
                <xsl:when test="Způsob = 'HM rovnoměrný'">typOdp.rovn
                </xsl:when>
                <xsl:when test="Způsob = 'HM zrychlený'">typOdp.zrych
                </xsl:when>
                <xsl:otherwise>typOdp.rovn</xsl:otherwise>
            </xsl:choose>
        </zpusOdpK>
        <sazba>
            <xsl:choose>
                <xsl:when test="Plán = '4R'">code:R1A</xsl:when>
            </xsl:choose>
        </sazba>
        <nahrUcetOdpK>
            <xsl:choose>
                <xsl:when test="Způsob = 'Neodpisovat'">nahrUcet.ne</xsl:when>
                <xsl:otherwise>nahrUcet.aPocMes</xsl:otherwise>

            </xsl:choose>
        </nahrUcetOdpK>
        <predpisUcetOdp>48</predpisUcetOdp>


    </xsl:template>

    <xsl:template name="changeDateFormat">
        <xsl:param name="inputDate"/>
        <xsl:variable name="den" select="substring-before($inputDate, '.')"/>
        <xsl:variable name="mesic"
                      select="substring-before(substring-after($inputDate, '.'), '.')"/>
        <xsl:variable name="rok"
                      select="substring(substring-before($inputDate, ' '), string-length(substring-before($inputDate, ' ')) - 3) "/>
        <xsl:value-of
          select="concat($rok,'-', $mesic,'-', $den)"/>
    </xsl:template>
</xsl:stylesheet>