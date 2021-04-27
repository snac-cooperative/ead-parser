<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:ead="urn:isbn:1-931666-22-9" xmlns:functx="http://www.functx.com" xmlns:snac="snac"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="urn:isbn:1-931666-22-9"  version="3.0">
	<!--
 @author Daniel Pitti 
 @license https://opensource.org/licenses/BSD-3-Clause BSD 3-Clause
 @copyright 2020 the Rector and Visitors of the University of Virginia
-->
	<!-- To convert from EAD2002 to EAD3, or vice-versa
	1. xmlns:ead="http://ead3.archivists.org/schema/" to/from xmlns:ead="urn:isbn:1-931666-22-9"
	2. xpath-default-namespace="http://ead3.archivists.org/schema/" to/from
	xpath-default-namespace="urn:isbn:1-931666-22-9"
	3. Search for namespace string and replace with appropriate string.
	4. change variable tempSourceId to empty string in both versions
	
	No changes to included stylesheets
	-->
	<!-- SAXON test command line for running this XSLT: 
		
		java -cp /usr/local/Cellar/saxon/9.9.1.7/libexec/saxon9he.jar net.sf.saxon.Query -t -qs:"current-date()"
		
		Output is current date plus additional meta-information on process.
		
		Documentation is here: https://www.saxonica.com/html/documentation9.7/using-xsl/commandline/
		
		The following command works locally:
		
		java -cp /usr/local/Cellar/saxon/9.9.1.7/libexec/saxon9he.jar net.sf.saxon.Transform -s:/Users/dvp4c/Work/SNACIII/OpenRefine/EAD/Driver/driver.xml -xsl:/Users/dvp4c/Work/SNACIII/OpenRefine/EAD/XSLT/EADtoOR/eadToORxsl.xsl -o:/Users/dvp4c/Work/SNACIII/OpenRefine/EAD/Extract/output.xml sourceFolderPath=../../SourceFiles/nypl2019 outputFolderPath=../extract/ 
		
		passing two parameters:
		
		param sourceFolderPath
		param outputFolderPath

		
		optional param: start [number] stop[number] can also be added for test purposes when you want to, let us say, process
		only 10 out of a 100 files.
		
		parsing the command line:
		
		-s:/Users/dvp4c/Work/SNACIII/OpenRefine/EAD/Driver/driver.xml This xml file actually exists, but it only serves as an
		xml file to pass in the command line as -s seems to be required. The content of driver.xml is:
		
<?xml version="1.0" encoding="UTF-8"?>
<driver>Used as the "driver" xml for eadToORxsl</driver>

Similarly, -o works in a similar fashion, though the path and folder exist, the results of running the XSLT does not
result in a file named output.xml. A complete existing path is necessary though; I suspect because I am using a relative path in the parameters;
if absolute paths were used I suspect the would overwrite -s and -o. But not sure.
		
 -->

	<!-- This is the primary XSLT and it imports two additional XSLT files, one with custom developed functions used in the
		processing, and the other has various global variables used in the processing. Local variable are situated as
		appropriate in the primary XSLT file, which is to say, this file. There are also additional local variables in the
		functions XSLT. relatorList.xml is also used by the XSTL. -->

	<xsl:import href="eadToORFunctions.xsl"/>
	<xsl:import href="eadToORVariables.xsl"/>

	<xsl:param name="sourceFolderPath">
		<xsl:text>../../SourceFiles/</xsl:text>
		<xsl:value-of select="$tempSourceID"/>
		<!-- URL for the remote folder in which there are ead encoded xml files; alternatively, if the files are "pre-fetched"
		to a SNAC server, then the URL to the folder on the SNAC server will be the sourceFolder-->
	</xsl:param>

	<xsl:param name="outputFolderPath">
		<xsl:text>../extract/</xsl:text>
		<!-- URL for the three tsv files created.  -->
	</xsl:param>

	<xsl:variable name="tempSourceID">
		<xsl:text></xsl:text>
		<!-- LoC nypl2019 -->
		<!-- reduce to empty string for production -->
	</xsl:variable>

	<!-- ******************************************** -->
	<!-- The following two parameters are by default set to process all uri-collection files. But command
	line can be used to process just a portion for testing purposes -->
	<xsl:param name="start" as="xs:integer">
		<xsl:text>1</xsl:text>
	</xsl:param>

	<xsl:param name="stop" as="xs:integer">
		<xsl:value-of select="$fileCount"/>
	</xsl:param>

	<!-- ******************************************** -->

	<xsl:variable name="findingAids" select="uri-collection(concat($sourceFolderPath, '?select=*.xml;recurse=yes'))">
		<!-- This pulls in the URI whereas collection() pulls in the document -->
	</xsl:variable>

	<xsl:variable name="fileCount">
		<xsl:value-of select="count($findingAids)"/>
	</xsl:variable>

	<xsl:strip-space elements="*"/>


	<xsl:key name="sourceCodeName" match="source" use="sourceCode"/>

	<!-- ************************************************************************************************** -->
	<!-- ************************************************************************************************** -->
	<xsl:variable name="processingType">
		<xsl:text>allOR</xsl:text>
		<!-- rawExtract stepOne stepTwo stepThree stepFour stepFive testRD 
		testCPF testJoin allOR -->
	</xsl:variable>

	<!-- for testing purposes method is xml; this is overridden in result-document for tsv tables -->
	<xsl:output indent="yes" method="xml"/>
	<!-- ************************************************************************************************** -->
	<!-- OpenRefine Column Labels -->
	<!-- ************************************************************************************************** -->
	<xsl:variable name="Abstract">Abstract</xsl:variable>
	<xsl:variable name="BiogHist">BiogHist</xsl:variable>
	<xsl:variable name="Citation">Citation</xsl:variable>
	<xsl:variable name="Citation-URL">Citation-URL</xsl:variable>
	<xsl:variable name="Citation-FoundData">Citation-FoundData</xsl:variable>
	<xsl:variable name="CPF-Relation-Type">CPF-Relation-Type</xsl:variable>
	<xsl:variable name="CPF-Source-ID">CPF-Source-ID</xsl:variable>
	<xsl:variable name="CPF-Source-ID-Anchor">CPF-Source-ID-Anchor</xsl:variable>
	<xsl:variable name="CPF-Source-ID-Target">CPF-Source-ID-Target</xsl:variable>
	<xsl:variable name="CPF-Type">CPF-Type</xsl:variable>
	<xsl:variable name="Date">Date</xsl:variable>
	<xsl:variable name="Extent">Extent</xsl:variable>
	<xsl:variable name="Activity">Activity</xsl:variable>
	<xsl:variable name="Language">Language</xsl:variable>
	<xsl:variable name="NameEntry">NameEntry</xsl:variable>
	<xsl:variable name="Occupation">Occupation</xsl:variable>
	<xsl:variable name="Place">Place</xsl:variable>
	<xsl:variable name="RD-Relation-Type">RD-Relation-Type</xsl:variable>
	<xsl:variable name="RD-Source-ID">RD-Source-ID</xsl:variable>
	<xsl:variable name="RD-Type">RD-Type</xsl:variable>
	<xsl:variable name="RD-URL">RD-URL</xsl:variable>
	<xsl:variable name="Repository">Repository</xsl:variable>
	<xsl:variable name="Related-ID">Related-ID</xsl:variable>
	<xsl:variable name="Subject">Subject</xsl:variable>
	<xsl:variable name="Title">Title</xsl:variable>

	<!-- ************************************************************************************************** -->
	<!-- ************************************************************************************************** -->
	<!-- ************************************************************************************************** -->
	<xsl:variable name="process">


		<xsl:for-each select="$findingAids[position() &gt;= $start and position() &lt;= $stop]">
			<!-- this loop processes each ead file. -->
			<xsl:variable name="eadPath">
				<xsl:value-of select="."/>
			</xsl:variable>


			<xsl:for-each select="document(.)">


				<!-- RAW EXTRACTION extracts all tagged names and origination, tagged or not. For the latter it attemts to determine type, and if unable
						to do so, defaults to persname. It also selects out, carefully, family names that have been mistagged as persname or corpname. -->
				<xsl:variable name="rawExtract">
					<!-- Extraction origination -->
					<xsl:for-each select="ead/archdesc/did/origination">

						<xsl:choose>
							<xsl:when test="persname | corpname | famname">

								<xsl:for-each select="(persname | corpname | famname)[matches(., '[\p{L}]')]">

									<snac:entity source="origination">
										<xsl:choose>
											<xsl:when test="snac:containsFamily(.)">

												<snac:rawExtract>
													<xsl:element name="snac:{name()}">
														<xsl:copy-of select="@*"/>
														<xsl:value-of select="normalize-space(.)"/>
													</xsl:element>
												</snac:rawExtract>
												<xsl:choose>
													<xsl:when test="@normal">
														<snac:normal type="attributeNormal">
															<snac:famname>
																<xsl:copy-of select="@*"/>
																<xsl:value-of select="normalize-space(@normal)"/>
															</snac:famname>
														</snac:normal>
													</xsl:when>
													<xsl:otherwise>
														<snac:normal type="provisional">
															<snac:famname>
																<xsl:copy-of select="@*"/>
																<xsl:value-of select="normalize-space(.)"/>
															</snac:famname>
														</snac:normal>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:when>
											<xsl:otherwise>
												<snac:rawExtract>
													<xsl:element name="snac:{name()}">
														<xsl:copy-of select="@*"/>
														<xsl:value-of select="normalize-space(.)"/>
													</xsl:element>
												</snac:rawExtract>
												<xsl:call-template name="attributeNormal"/>
											</xsl:otherwise>
										</xsl:choose>
									</snac:entity>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if test=". != ''">
									<snac:entity source="origination">
										<snac:rawExtract type="unknown">
											<xsl:element name="snac:{name()}">
												<xsl:copy-of select="@*"/>
												<xsl:value-of select="normalize-space(.)"/>
											</xsl:element>
										</snac:rawExtract>
										<xsl:choose>
											<xsl:when test="contains(lower-case(.), 'family')">
												<snac:normal type="tenuous">
													<snac:famname>
														<xsl:value-of select="."/>
													</snac:famname>
												</snac:normal>
											</xsl:when>
											<xsl:when test="snac:containsCorporateWord(.)">
												<snac:normal type="tenuous">
													<snac:corpname>
														<xsl:value-of select="."/>
													</snac:corpname>
												</snac:normal>
											</xsl:when>
											<xsl:when test="contains(., ',')">
												<!-- This is simply a wager that personal names far outnumber corporate and family names, thus ... more often right than wrong. Perhaps. -->
												<snac:normal type="tenuous">
													<snac:persname>
														<xsl:value-of select="."/>
													</snac:persname>
												</snac:normal>
											</xsl:when>
											<xsl:otherwise>
												<snac:normal type="tenuous">
													<snac:persname>
														<xsl:value-of select="."/>
													</snac:persname>
												</snac:normal>
											</xsl:otherwise>
										</xsl:choose>
									</snac:entity>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
					<!-- extract control access -->

					<xsl:for-each select="ead/archdesc//controlaccess/(persname | corpname | famname)[matches(., '[\p{L}]')]">
						<snac:entity source="controlaccess">
							<xsl:if
								test="contains(lower-case(@role), 'correspond') or contains(lower-case(@role), 'crp') or lower-case(@role) = 'corr' or contains(lower-case(.), 'correspond')">
								<xsl:attribute name="correspondent">
									<xsl:text>yes</xsl:text>
								</xsl:attribute>
							</xsl:if>

							<xsl:choose>
								<xsl:when test="snac:containsFamily(.)">

									<snac:rawExtract>
										<xsl:element name="snac:{name()}">
											<xsl:copy-of select="@*"/>
											<xsl:value-of select="normalize-space(.)"/>
										</xsl:element>
									</snac:rawExtract>
									<xsl:choose>
										<xsl:when test="@normal">
											<snac:normal type="attributeNormal">
												<snac:famname>
													<xsl:copy-of select="@*"/>
													<xsl:value-of select="normalize-space(@normal)"/>
												</snac:famname>
											</snac:normal>
										</xsl:when>
										<xsl:otherwise>
											<snac:normal type="provisional">
												<snac:famname>
													<xsl:copy-of select="@*"/>
													<xsl:value-of select="normalize-space(.)"/>
												</snac:famname>
											</snac:normal>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<snac:rawExtract>
										<xsl:element name="snac:{name()}">
											<xsl:copy-of select="@*"/>
											<xsl:value-of select="normalize-space(.)"/>
										</xsl:element>
									</snac:rawExtract>
									<xsl:call-template name="attributeNormal"/>
								</xsl:otherwise>
							</xsl:choose>
						</snac:entity>
					</xsl:for-each>
					<!-- extract scope and content -->
					<xsl:for-each select="ead/archdesc//scopecontent/(persname | corpname | famname)[matches(., '[\p{L}]')]">
						<snac:entity source="controlaccess">
							<xsl:choose>
								<xsl:when test="snac:containsFamily(.)">
									<snac:rawExtract>
										<xsl:element name="snac:{name()}">
											<xsl:copy-of select="@*"/>
											<xsl:value-of select="normalize-space(.)"/>
										</xsl:element>
									</snac:rawExtract>
									<xsl:choose>
										<xsl:when test="@normal">
											<snac:normal type="attributeNormal">
												<snac:famname>
													<xsl:copy-of select="@*"/>
													<xsl:value-of select="normalize-space(@normal)"/>
												</snac:famname>
											</snac:normal>
										</xsl:when>
										<xsl:otherwise>
											<snac:normal type="provisional">
												<snac:famname>
													<xsl:copy-of select="@*"/>
													<xsl:value-of select="normalize-space(.)"/>
												</snac:famname>
											</snac:normal>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<snac:rawExtract>
										<xsl:element name="snac:{name()}">
											<xsl:copy-of select="@*"/>
											<xsl:value-of select="normalize-space(.)"/>
										</xsl:element>
									</snac:rawExtract>
									<xsl:call-template name="attributeNormal"/>
								</xsl:otherwise>
							</xsl:choose>
						</snac:entity>
					</xsl:for-each>
					<!-- extract dsc -->
					<xsl:for-each
						select="ead/archdesc//dsc//(persname | corpname | famname)[matches(., '[\p{L}]')][not(parent::controlaccess)][not(parent::scopecontent)]">

						<!--		two variables: both preprocess using new routines, 
											but groups into Correspondence and not; for former, 
											process the group to add Correspondence to the end-->
						<snac:entity source="dsc">
							<xsl:if
								test="
									(ancestor::*[ancestor::dsc]/did[contains(lower-case(unittitle[1]), 'correspond')] and .[parent::unittitle])
									or
									(ancestor::*[ancestor::dsc]/did[contains(lower-case(unittitle[1]), 'letter')] and .[parent::unittitle]) or
									
									contains(lower-case(@role), 'correspond') or
									contains(lower-case(@role), 'crp') or
									contains(lower-case(.), 'correspond') or
									lower-case(@role) = 'corr'
									">
								<xsl:attribute name="correspondent">
									<xsl:text>yes</xsl:text>
								</xsl:attribute>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="snac:containsFamily(.)">

									<snac:rawExtract>
										<xsl:element name="snac:{name()}">
											<xsl:copy-of select="@*"/>
											<xsl:value-of select="normalize-space(.)"/>
										</xsl:element>
									</snac:rawExtract>
									<xsl:choose>
										<xsl:when test="@normal">
											<snac:normal type="attributeNormal">
												<snac:famname>
													<xsl:copy-of select="@*"/>
													<xsl:value-of select="normalize-space(@normal)"/>
												</snac:famname>
											</snac:normal>
										</xsl:when>
										<xsl:otherwise>
											<snac:normal type="provisional">
												<snac:famname>
													<xsl:copy-of select="@*"/>
													<xsl:value-of select="normalize-space(.)"/>
												</snac:famname>
											</snac:normal>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<snac:rawExtract>
										<xsl:element name="snac:{name()}">
											<xsl:copy-of select="@*"/>
											<xsl:value-of select="normalize-space(.)"/>
										</xsl:element>
									</snac:rawExtract>
									<xsl:call-template name="attributeNormal"/>
								</xsl:otherwise>
							</xsl:choose>
							<!--context>
										<xsl:copy-of select="parent::*"/>
									</context-->
							<xsl:if test="parent::*/parent::did/unittitle/unitdate">
								<xsl:for-each select="parent::*/parent::did/unittitle/unitdate">
									<xsl:for-each select="tokenize(snac:getDateFromUnitdate(.), '\s')">
										<!-- looks only for tokens in the date that are NNNN, and thus ignores months and days entered as nunmbers -->
										<xsl:if test="matches(., '^[\d]{3,4}$')">
											<snac:activeDate>
												<xsl:number value="." format="0001"/>
											</snac:activeDate>
										</xsl:if>
									</xsl:for-each>
								</xsl:for-each>
							</xsl:if>
						</snac:entity>
					</xsl:for-each>
				</xsl:variable>

				<!-- NORMALIZE STEP ONE: Removes any entity with the words unknown or various, as these are dubious or combine name and not name components. 
						Normalizes entries that are not based on @normal. Every outgoing entity has a normal, either attributeNormal or
						regEx.  -->
				<xsl:variable name="normalizeStepOne">
					<xsl:for-each select="$rawExtract/snac:entity">

						<xsl:choose>
							<xsl:when
								test="contains(lower-case(snac:rawExtract/*), 'unknown') or contains(lower-case(snac:rawExtract/*), 'various')">
								<!-- This removes entries that contain unknown and various, as in either case, the entry is either not useful
										or difficult to sort out. -->
								<!--xsl:message>
											<xsl:text>Removed: </xsl:text>
											<xsl:value-of select="rawExtract"/>
										</xsl:message-->
							</xsl:when>

							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="snac:normal/snac:persname">
										<snac:entity>
											<xsl:copy-of select="* | @*"/>
											<xsl:if test="snac:normal[not(@type = 'attributeNormal')]/snac:persname">
												<!-- This on normalizes those that do not have a @normal in rawExtract -->
												<snac:normal type="regExed">
													<snac:persname>
														<xsl:copy-of select="snac:normal/snac:persname/@*"/>
														<xsl:value-of
															select="
																normalize-space(
																snac:stripStringAfterDateInPersname(
																snac:removeApostropheLowercaseSSpace(
																snac:removeBeforeHyphen2(
																snac:fixSpacing(
																snac:fixDatesReplaceActiveWithFl(
																snac:fixDatesRemoveParens(
																snac:fixCommaHyphen2(
																snac:fixHypen2Paren(
																snac:removeTrailingInappropriatePunctuation(
																snac:removeInitialNonWord(
																snac:removeInitialTrailingParen(
																snac:removeBrackets(
																snac:removeInitialHypen(
																snac:removeQuotes(
																snac:fixSpaceComma(
																snac:stripTrailingPerformer(snac:normal/snac:persname))))))))))))))))
																)"
														/>
													</snac:persname>
												</snac:normal>
											</xsl:if>
											<xsl:call-template name="extractOccupationOrFunction">
												<xsl:with-param name="entry">
													<xsl:copy-of select="./snac:rawExtract/*"/>
												</xsl:with-param>
											</xsl:call-template>
										</snac:entity>
									</xsl:when>
									<xsl:when test="snac:normal/snac:famname">
										<snac:entity>
											<xsl:copy-of select="* | @*"/>
											<xsl:if test="snac:normal[not(@type = 'attributeNormal')]/snac:famname">
												<snac:normal type="regExed">
													<snac:famname>
														<xsl:choose>
															<xsl:when test="not(contains(snac:removeBeforeHyphen2(snac:normal/snac:famname), ' '))">
																<xsl:value-of select="snac:removePunctuation(snac:removeBeforeHyphen2(snac:normal/snac:famname))"/>
																<xsl:text> [family]</xsl:text>
															</xsl:when>
															<xsl:otherwise>
																<xsl:value-of select="snac:removeBeforeHyphen2(snac:normal/snac:famname)"/>
															</xsl:otherwise>
														</xsl:choose>
													</snac:famname>
												</snac:normal>
											</xsl:if>
											<xsl:call-template name="extractOccupationOrFunction">
												<xsl:with-param name="entry">
													<xsl:copy-of select="./snac:rawExtract/*"/>
												</xsl:with-param>
											</xsl:call-template>
										</snac:entity>
									</xsl:when>
									<xsl:when test="snac:normal/snac:corpname">
										<snac:entity>
											<xsl:copy-of select="* | @*"/>
											<xsl:if test="snac:normal[not(@type = 'attributeNormal')]/snac:corpname">
												<snac:normal type="regExed">
													<snac:corpname>
														<xsl:value-of
															select="
																normalize-space(
																snac:removeBeforeHyphen2(
																snac:fixDatesRemoveParens(
																snac:fixCommaHyphen2(
																snac:fixHypen2Paren(
																snac:removeTrailingInappropriatePunctuation(
																snac:removeInitialTrailingParen(
																snac:removeBrackets(
																snac:removeInitialHypen(
																snac:removeQuotes(
																snac:stripTrailingPerformer(snac:normal/snac:corpname))))))))))
																)"
														/>
													</snac:corpname>
												</snac:normal>
											</xsl:if>
											<xsl:call-template name="extractOccupationOrFunction">
												<xsl:with-param name="entry">
													<xsl:copy-of select="./snac:rawExtract/*"/>
												</xsl:with-param>
											</xsl:call-template>
										</snac:entity>

									</xsl:when>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:variable>

				<!-- NORMALIZE STEP TWO: Adds <normalForMatch> to <entity> and exist dates -->
				<xsl:variable name="normalizeStepTwo">
					<xsl:for-each select="$normalizeStepOne/snac:entity">
						<snac:entity>
							<xsl:copy-of select="@* | *"/>
							<snac:normalForMatch>
								<xsl:choose>
									<xsl:when test="snac:normal[@type = 'attributeNormal']">
										<xsl:value-of select="snac:normalizeString(snac:normal[@type = 'attributeNormal'])"/>
									</xsl:when>
									<xsl:when test="snac:normal[@type = 'regExed']">
										<xsl:value-of select="snac:normalizeString(snac:normal[@type = 'regExed'])"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="snac:normalizeString(snac:normal[@type = 'provisional'])"/>
									</xsl:otherwise>
								</xsl:choose>
							</snac:normalForMatch>

							<!-- Make existDate for persname with dates in name -->
							<xsl:choose>
								<xsl:when test="snac:normal[@type = 'attributeNormal']/snac:persname">
									<xsl:call-template name="existDateFromPersname">
										<xsl:with-param name="tempString">
											<xsl:value-of select="snac:normal[@type = 'attributeNormal']/snac:persname"/>
										</xsl:with-param>
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="snac:normal[@type = 'regExed']/snac:persname">
									<xsl:call-template name="existDateFromPersname">
										<xsl:with-param name="tempString">
											<xsl:value-of select="snac:normal[@type = 'regExed']/snac:persname"/>
										</xsl:with-param>
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="snac:normal[@type = 'provisional']/snac:persname">
									<xsl:call-template name="existDateFromPersname">
										<xsl:with-param name="tempString">
											<xsl:value-of select="snac:normal[@type = 'provisional']/snac:persname"/>
										</xsl:with-param>
									</xsl:call-template>
								</xsl:when>
							</xsl:choose>

						</snac:entity>
					</xsl:for-each>
				</xsl:variable>

				<!-- NORMALIZE STEP THREE: Eliminates exact (after punctuation and spelling normaizing) duplicates. -->
				<xsl:variable name="normalizeStepThree">
					<xsl:for-each select="$normalizeStepTwo">

						<xsl:variable name="group">
							<xsl:for-each-group select="snac:entity" group-by="snac:normalForMatch">
								<snac:group>
									<xsl:for-each select="current-group()">
										<snac:entity>
											<xsl:copy-of select="@* | *[not(self::snac:occupation)]"/>
										</snac:entity>
									</xsl:for-each>
									<xsl:for-each select="current-group()">
										<xsl:copy-of select="snac:occupation"/>
									</xsl:for-each>
								</snac:group>
							</xsl:for-each-group>
						</xsl:variable>

						<xsl:for-each select="$group/snac:group">

							<xsl:variable name="count">
								<xsl:value-of select="count(snac:entity)"/>
							</xsl:variable>

							<xsl:variable name="correspondent">
								<xsl:if test="snac:entity/@correspondent = 'yes'">
									<xsl:text>yes</xsl:text>
								</xsl:if>
							</xsl:variable>

							<xsl:variable name="activeDates">
								<xsl:for-each-group select="snac:entity/snac:activeDate" group-by=".">
									<xsl:sort/>
									<xsl:for-each select="current-grouping-key()">
										<snac:activeDate>
											<xsl:value-of select="."/>
										</snac:activeDate>
									</xsl:for-each>
								</xsl:for-each-group>
							</xsl:variable>

							<xsl:variable name="countActiveDates">
								<xsl:value-of select="count($activeDates/*)"/>
							</xsl:variable>

							<xsl:variable name="occupations">
								<xsl:for-each-group select="snac:occupation" group-by=".">
									<xsl:sort/>
									<xsl:for-each select="current-grouping-key()">
										<snac:occupation>
											<xsl:value-of select="."/>
										</snac:occupation>
									</xsl:for-each>
								</xsl:for-each-group>
							</xsl:variable>

							<xsl:choose>
								<!-- add correspondent to selection. -->
								<xsl:when test="snac:entity[@source = 'origination']">
									<xsl:for-each select="snac:entity[@source = 'origination'][1]">
										<snac:entity>
											<xsl:copy-of select="@*"/>
											<xsl:attribute name="count">
												<xsl:value-of select="$count"/>
											</xsl:attribute>
											<xsl:if test="$correspondent = 'yes'">
												<xsl:attribute name="correspondent">
													<xsl:text>yes</xsl:text>
												</xsl:attribute>
											</xsl:if>
											<xsl:copy-of select="*[not(self::snac:activeDate)]"/>
											<xsl:choose>
												<xsl:when test="$countActiveDates = 0"/>
												<xsl:when test="$countActiveDates = 1">
													<xsl:copy-of select="$activeDates/snac:activeDate"/>
												</xsl:when>
												<xsl:when test="$countActiveDates &gt; 1">
													<xsl:copy-of select="$activeDates/snac:activeDate[1]"/>
													<xsl:copy-of select="$activeDates/snac:activeDate[position() = $countActiveDates]"/>
												</xsl:when>
											</xsl:choose>
											<xsl:for-each select="$occupations/snac:occupation">
												<xsl:copy-of select="."/>
											</xsl:for-each>
										</snac:entity>
									</xsl:for-each>

								</xsl:when>
								<xsl:when test="snac:entity[@source = 'controlaccess']">
									<xsl:for-each select="snac:entity[@source = 'controlaccess'][1]">
										<snac:entity>
											<xsl:copy-of select="@*"/>
											<xsl:attribute name="count">
												<xsl:value-of select="$count"/>
											</xsl:attribute>
											<xsl:if test="$correspondent = 'yes'">
												<xsl:attribute name="correspondent">
													<xsl:text>yes</xsl:text>
												</xsl:attribute>
											</xsl:if>
											<xsl:copy-of select="*[not(self::snac:activeDate)]"/>
											<xsl:choose>
												<xsl:when test="$countActiveDates = 0"/>
												<xsl:when test="$countActiveDates = 1">
													<xsl:copy-of select="$activeDates/snac:activeDate"/>
												</xsl:when>
												<xsl:when test="$countActiveDates &gt; 1">
													<xsl:copy-of select="$activeDates/snac:activeDate[1]"/>
													<xsl:copy-of select="$activeDates/snac:activeDate[position() = $countActiveDates]"/>
												</xsl:when>
											</xsl:choose>
											<xsl:for-each select="$occupations/snac:occupation">
												<xsl:copy-of select="."/>
											</xsl:for-each>
										</snac:entity>
									</xsl:for-each>
								</xsl:when>
								<xsl:when test="snac:entity[@source = 'dsc']">
									<xsl:for-each select="snac:entity[@source = 'dsc'][1]">
										<snac:entity>
											<xsl:copy-of select="@*"/>
											<xsl:attribute name="count">
												<xsl:value-of select="$count"/>
											</xsl:attribute>
											<xsl:if test="$correspondent = 'yes'">
												<xsl:attribute name="correspondent">
													<xsl:text>yes</xsl:text>
												</xsl:attribute>
											</xsl:if>
											<xsl:copy-of select="*[not(self::snac:activeDate)]"/>
											<xsl:choose>
												<xsl:when test="$countActiveDates = 0"/>
												<xsl:when test="$countActiveDates = 1">
													<xsl:copy-of select="$activeDates/snac:activeDate"/>
												</xsl:when>
												<xsl:when test="$countActiveDates &gt; 1">
													<xsl:copy-of select="$activeDates/snac:activeDate[1]"/>
													<xsl:copy-of select="$activeDates/snac:activeDate[position() = $countActiveDates]"/>
												</xsl:when>
											</xsl:choose>
											<xsl:for-each select="$occupations/snac:occupation">
												<xsl:copy-of select="."/>
											</xsl:for-each>
										</snac:entity>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<error>Something went wrong in selecting the entity!</error>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:for-each>


				</xsl:variable>

				<!-- NORMALIZE STEP FOUR: Flags for discard all entries consisting of one name component when the component is 
							found in a name string with two or more components. -->
				<xsl:variable name="normalizeStepFour">

					<xsl:for-each select="$normalizeStepThree">

						<xsl:variable name="singleTokenSet">
							<xsl:for-each select="snac:entity[snac:normal/snac:persname]">
								<xsl:if test="snac:countTokens(snac:normalForMatch) = 1">
									<xsl:copy-of select="."/>
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>

						<xsl:variable name="multipleTokenSet">
							<xsl:for-each select="snac:entity[snac:normal/snac:persname]">
								<xsl:if test="snac:countTokens(snac:normalForMatch) &gt; 1">
									<xsl:copy-of select="."/>
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>

						<xsl:variable name="multipleTokenString">
							<xsl:for-each select="snac:entity[snac:normal/snac:persname]">
								<xsl:if test="snac:countTokens(snac:normalForMatch) &gt; 1">
									<xsl:value-of select="snac:normalForMatch"/>
									<xsl:text> </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>

						<!-- check for each enitity/normalized for match  -->

						<xsl:for-each select="$singleTokenSet/snac:entity">
							<xsl:variable name="tempString" as="xs:string">
								<xsl:value-of select="snac:normalForMatch"/>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="exists(index-of(tokenize($multipleTokenString, '\s'), snac:normalForMatch))">
									<snac:entity discard="yes">
										<xsl:copy-of select="@* | *"/>
									</snac:entity>
								</xsl:when>

								<xsl:otherwise>
									<xsl:copy-of select="."/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>

						<xsl:for-each select="$multipleTokenSet/snac:entity">
							<xsl:copy-of select="."/>
						</xsl:for-each>

						<xsl:for-each select="*[not(snac:normal/snac:persname)]">
							<xsl:copy-of select="."/>
						</xsl:for-each>
					</xsl:for-each>

				</xsl:variable>

				<!-- NORMALIZE STEP FIVE: Adds the identifier component for each entity, c or r, and number  -->
				<!-- Is this the final step? -->
				<xsl:variable name="normalizeStepFive">
					<xsl:variable name="selectBioghist">
						<xsl:call-template name="selectBioghist"/>
					</xsl:variable>

					<xsl:for-each select="$normalizeStepFour">
						<xsl:variable name="originationCount">
							<xsl:value-of select="count(snac:entity[@source = 'origination'])"/>
						</xsl:variable>
						<xsl:variable name="controlaccessCount">
							<xsl:value-of select="count(snac:entity[@source = 'controlaccess'])"/>
						</xsl:variable>

						<xsl:for-each select="snac:entity[not(@discard = 'yes')]">
							<snac:entity>
								<xsl:copy-of select="@*"/>
								<xsl:attribute name="recordId">
									<xsl:value-of select="snac:getBaseIdName(snac:getFileName($eadPath))"/>
									<xsl:choose>
										<xsl:when test=".[@source = 'origination' and not(@discard = 'yes')]">
											<xsl:text>.c</xsl:text>
											<xsl:number count="snac:entity[@source = 'origination' and not(@discard = 'yes')]" format="01"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>.r</xsl:text>
											<xsl:number count="snac:entity[not(@source = 'origination') and not(@discard = 'yes')]" format="001"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>
								<xsl:attribute name="originationCount">
									<xsl:value-of select="$originationCount"/>
								</xsl:attribute>
								<xsl:attribute name="controlaccessCount">
									<xsl:value-of select="$controlaccessCount"/>
								</xsl:attribute>
								<snac:normalFinal>
									<xsl:choose>
										<xsl:when test="snac:normal[@type = 'attributeNormal']">
											<xsl:copy-of select="snac:normal[@type = 'attributeNormal']"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:copy-of select="snac:normal[@type = 'regExed']/*"/>
										</xsl:otherwise>
									</xsl:choose>
								</snac:normalFinal>
								<xsl:copy-of select="*"/>
							</snac:entity>
						</xsl:for-each>
					</xsl:for-each>

					<xsl:call-template name="aboutOriginationEntity">
						<xsl:with-param name="eadPath" select="$eadPath"/>
					</xsl:call-template>
				</xsl:variable>


				<!-- ****************************************************************** -->
				<!-- ****************************************************************** -->
				<!-- ****************************************************************** -->

				<xsl:choose>
					<xsl:when test="$processingType = 'rawExtract'">
						<snac:oneFindingAid source="{$eadPath}">
							<xsl:for-each select="$rawExtract">
								<xsl:for-each select="*">
									<xsl:copy-of select="."/>
								</xsl:for-each>
							</xsl:for-each>
						</snac:oneFindingAid>
					</xsl:when>
					<xsl:when test="$processingType = 'stepOne'">
						<snac:oneFindingAid source="{$eadPath}">
							<xsl:for-each select="$normalizeStepOne">
								<xsl:for-each select="*">
									<xsl:copy-of select="."/>
								</xsl:for-each>
							</xsl:for-each>
						</snac:oneFindingAid>
					</xsl:when>
					<xsl:when test="$processingType = 'stepTwo'">
						<snac:oneFindingAid source="{$eadPath}">
							<xsl:for-each select="$normalizeStepTwo">
								<xsl:for-each select="*">
									<xsl:copy-of select="."/>
								</xsl:for-each>
							</xsl:for-each>
						</snac:oneFindingAid>
					</xsl:when>
					<xsl:when test="$processingType = 'stepThree'">
						<snac:oneFindingAid source="{$eadPath}">
							<xsl:for-each select="$normalizeStepThree">
								<xsl:for-each select="*">
									<xsl:copy-of select="."/>
								</xsl:for-each>
							</xsl:for-each>
						</snac:oneFindingAid>
					</xsl:when>
					<xsl:when test="$processingType = 'stepFour'">
						<snac:oneFindingAid source="{$eadPath}">
							<xsl:for-each select="$normalizeStepFour">
								<xsl:for-each select="*">
									<xsl:copy-of select="."/>
								</xsl:for-each>
							</xsl:for-each>
						</snac:oneFindingAid>
					</xsl:when>
					<xsl:when
						test="
							$processingType = 'stepFive' or $processingType = 'testCPF' or $processingType = 'testRD'
							or $processingType = 'testJoin' or $processingType = 'allOR'">
						<snac:oneFindingAid source="{$eadPath}">
							<xsl:for-each select="$normalizeStepFive">
								<xsl:for-each select="*">
									<xsl:copy-of select="."/>
								</xsl:for-each>
							</xsl:for-each>
						</snac:oneFindingAid>
					</xsl:when>
				</xsl:choose>


				<!-- ****************************************************************** -->
				<!-- ****************************************************************** -->
				<!-- ****************************************************************** -->



				<!-- end of for each document(.) -->
			</xsl:for-each>
			<!-- end of snac:i -->
		</xsl:for-each>
		<!-- end of each fileList batch -->

	</xsl:variable>

	<xsl:template match="/">

		<xsl:choose>
			<xsl:when test="$processingType = 'CPFOut'">
				<xsl:for-each select="$process/*">
					<xsl:variable name="recordId" select="./control/recordId" xpath-default-namespace="urn:isbn:1-931666-22-9" />
					<xsl:result-document href="{$outputFolderPath}{$tempSourceID}/{$recordId}.xml" indent="yes">
						<xsl:processing-instruction name="oxygen">
							<xsl:text>RNGSchema="http://socialarchive.iath.virginia.edu/shared/cpf.rng" type="xml"</xsl:text>
						</xsl:processing-instruction>
						<xsl:text>&#xA;</xsl:text>
						<xsl:copy-of select="."/>
					</xsl:result-document>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$processingType = 'testRD'">
				<xsl:call-template name="RD-OR"/>
			</xsl:when>
			<xsl:when test="$processingType = 'testCPF'">
				<xsl:call-template name="CPF-OR"/>
			</xsl:when>
			<xsl:when test="$processingType = 'testJoin'">
				<xsl:call-template name="Join-OR"/>
			</xsl:when>
			<xsl:when test="$processingType = 'allOR'">
				<!-- Make RD -->
				<xsl:call-template name="RD-OR"/>

				<!-- Make CPF -->
				<xsl:call-template name="CPF-OR"/>
				<!-- Make Join -->
				<xsl:call-template name="Join-OR"/>
			</xsl:when>
			<xsl:otherwise>
				<report>
					<xsl:for-each select="$process/*">
						<xsl:copy-of select="."/>
					</xsl:for-each>
				</report>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>



	<xsl:template name="RD-OR">
		<xsl:result-document method="text" href="{$outputFolderPath}{$tempSourceID}/{$tempSourceID}RD-Table.tsv">
			<!-- The following creates first (label) row of table -->
			<xsl:value-of select="$RD-Source-ID"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$RD-Type"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$Title"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$Date"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$Language"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$Extent"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$Repository"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$RD-URL"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$Abstract"/>
			<xsl:text>&#xA;</xsl:text>
			<!-- new row -->
			<xsl:for-each select="$process/snac:oneFindingAid/snac:otherData">
				<!-- Source-RD-ID -->
				<xsl:value-of select="normalize-space(snac:eadPath)"/>
				<xsl:text>&#009;</xsl:text>
				<!-- RD-Role -->
				<xsl:text>ArchivalResource</xsl:text>
				<xsl:text>&#009;</xsl:text>
				<!-- Title -->
				<xsl:value-of select="normalize-space(ead:did/ead:unittitle)"/>
				<xsl:text> &#009;</xsl:text>
				<!-- Date -->
				<xsl:for-each select="ead:did/ead:unitdate">
					<xsl:value-of select="normalize-space(.)"/>
					<xsl:choose>
						<xsl:when test="position() = last()"/>
						<xsl:otherwise>
							<xsl:text>; </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				<xsl:text>&#009;</xsl:text>

				<!-- Lang -->
				<xsl:for-each select="ead:did/ead:langmaterial">
					<xsl:choose>
						<xsl:when test="not(ead:language or ead:languageset)">
							<xsl:value-of select="normalize-space(.)"/>

						</xsl:when>
						<xsl:when test="ead:descriptivenote">
							<xsl:value-of select="normalize-space(ead:descriptivenote)"/>

						</xsl:when>
						<xsl:when test="ead:languageset">
							<xsl:for-each select="ead:languageset">
								<xsl:value-of select="normalize-space(ead:language)"/>
								<xsl:choose>
									<xsl:when test="position() = last()"/>
									<xsl:otherwise>
										<xsl:text>; </xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="ead:language">
								<xsl:value-of select="normalize-space(.)"/>
								<xsl:choose>
									<xsl:when test="position() = last()"/>
									<xsl:otherwise>
										<xsl:text>; </xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>


				</xsl:for-each>

				<xsl:text>&#009;</xsl:text>
				<!-- Extent -->
				<xsl:choose>
					<xsl:when test="ead:did/ead:physdesc[exists(*)]">
						<xsl:for-each select="ead:did/ead:physdesc/*">
							<xsl:value-of select="normalize-space(.)"/>
							<xsl:choose>
								<xsl:when test="position() = last()"/>
								<xsl:otherwise>
									<xsl:text>; </xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="ead:did/ead:physdesc">
							<xsl:value-of select="normalize-space(.)"/>
							<xsl:choose>
								<xsl:when test="position() = last()"/>
								<xsl:otherwise>
									<xsl:text>; </xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>&#009;</xsl:text>
				<!-- Repository -->
				<xsl:value-of select="normalize-space(ead:did/ead:repository/ead:corpname)"/>
				<xsl:text>&#009;</xsl:text>
				<!-- RD-URL -->
				<xsl:value-of select="ead:eadid/@url | ead:recordid/@instanceurl"/>
				<xsl:text>&#009;</xsl:text>
				<!-- Abtract -->
				<xsl:value-of select="normalize-space(replace(ead:did/ead:abstract, $quoteLiteral, '&amp;quot;'))"/>
				<xsl:text>&#xA;</xsl:text>
			</xsl:for-each>

		</xsl:result-document>


	</xsl:template>

	<xsl:template name="CPF-OR">
		<xsl:result-document method="text" href="{$outputFolderPath}{$tempSourceID}/{$tempSourceID}CPF-Table.tsv">
			<!-- The following creates first (label) row of table -->
			<xsl:value-of select="$CPF-Source-ID"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$Related-ID"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$CPF-Type"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$NameEntry"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$Date"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$Subject"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$Place"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$Occupation"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$Activity"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$BiogHist"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$Citation"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$Citation-URL"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$Citation-FoundData"/>
			<xsl:text>&#xA;</xsl:text>

			<xsl:for-each select="$process/snac:oneFindingAid/snac:entity">
				<!-- Source-CPF-ID -->
				<xsl:value-of select="@recordId"/>
				<xsl:text>&#009;</xsl:text>
				<!-- LoC-ID -->
				<xsl:if test="snac:normalFinal/*/@authfilenumber">
					<xsl:choose>
						<xsl:when test="contains(snac:normalFinal/*/@authfilenumber, 'http://id.loc.gov/authorities/names/')">
							<xsl:value-of
								select="substring-after(normalize-space(snac:normalFinal/*/@authfilenumber), 'http://id.loc.gov/authorities/names/')"
							/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(snac:normalFinal/*/@authfilenumber)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>

				<xsl:text>&#009;</xsl:text>
				<!-- entityType -->
				<xsl:choose>
					<xsl:when test="exists(snac:normalFinal/snac:persname)">
						<xsl:text>person</xsl:text>
					</xsl:when>
					<xsl:when test="exists(snac:normalFinal/snac:corpname)">
						<xsl:text>corporateBody</xsl:text>
					</xsl:when>
					<xsl:when test="exists(snac:normalFinal/snac:famname)">
						<xsl:text>family</xsl:text>
					</xsl:when>
				</xsl:choose>
				<xsl:text>&#009;</xsl:text>
				<!-- nameEntry -->
				<xsl:value-of select="normalize-space(snac:normalFinal)"/>
				<xsl:text>&#009;</xsl:text>

				<!-- Date (Exist) -->
				<xsl:for-each select="snac:existDates/snac:dateRange">
					<xsl:for-each select="*[not(. = '')]">
						<xsl:value-of select="normalize-space(./@snac:standardDate)"/>
						<xsl:text>^</xsl:text>
						<xsl:value-of select="substring-after(normalize-space(./@snac:localType), '#')"/>
						<xsl:choose>
							<xsl:when test="position() = last()"/>
							<xsl:otherwise>
								<xsl:text>#</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:for-each>
				<xsl:text>&#009;</xsl:text>

				<!-- AssociatedSubject -->
				<xsl:if test="@source = 'origination'">
					<xsl:for-each select="ancestor::snac:oneFindingAid/snac:otherData/ead:subject">
						<xsl:value-of select="normalize-space(.)"/>
						<xsl:choose>
							<xsl:when test="position() = last()"/>
							<xsl:otherwise>
								<xsl:text>#</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:if>
				<xsl:text>&#009;</xsl:text>
				<!-- AssociatedPlace -->
				<xsl:if test="@source = 'origination'">
					<xsl:for-each select="ancestor::snac:oneFindingAid/snac:otherData/snac:geognameGroup/snac:normalized">


						<xsl:value-of select="normalize-space(.)"/>
						<xsl:choose>
							<xsl:when test="position() = last()"/>
							<xsl:otherwise>
								<xsl:text>#</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:if>
				<xsl:text>&#009;</xsl:text>
				<!-- Occupation -->
				<xsl:if test="@source = 'origination'">
					<xsl:for-each select="ancestor::snac:oneFindingAid/snac:otherData/ead:occupation">
						<xsl:value-of select="normalize-space(.)"/>
						<xsl:choose>
							<xsl:when test="position() = last()"/>
							<xsl:otherwise>
								<xsl:text>#</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:if>
				<xsl:text>&#009;</xsl:text>
				<!-- Function -->
				<xsl:if test="@source = 'origination'">
					<xsl:for-each select="ancestor::snac:oneFindingAid/snac:otherData/ead:function">
						<xsl:value-of select="normalize-space(.)"/>
						<xsl:choose>
							<xsl:when test="position() = last()"/>
							<xsl:otherwise>
								<xsl:text>#</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:if>
				<xsl:text>&#009;</xsl:text>
				<!-- biogHist -->
				<xsl:if test="@source = 'origination'">
					<xsl:for-each select="ancestor::snac:oneFindingAid/snac:otherData/ead:bioghist">
						<xsl:text disable-output-escaping="yes">&lt;biogHist&gt;</xsl:text>
						<xsl:for-each select=".//*">
							<xsl:text disable-output-escaping="yes">&lt;</xsl:text>
							<xsl:value-of select="name()"/>
							<xsl:text disable-output-escaping="yes">&gt;</xsl:text>
							<xsl:value-of select="normalize-space(.)"/>
							<xsl:text disable-output-escaping="yes">&lt;/</xsl:text>
							<xsl:value-of select="name()"/>
							<xsl:text disable-output-escaping="yes">&gt;</xsl:text>
						</xsl:for-each>
						<xsl:text disable-output-escaping="yes">&lt;/biogHist&gt;</xsl:text>
					</xsl:for-each>
				</xsl:if>
				<!-- end of cell -->
				<xsl:text>&#009;</xsl:text>


				<!-- Citation (of source evidence) -->
				<xsl:value-of select="normalize-space(../snac:otherData/ead:did/ead:unittitle)"/>



				<xsl:if test="../snac:otherData/ead:did/ead:unitdate">
					<xsl:text>, </xsl:text>
					<xsl:for-each select="../snac:otherData/ead:did/ead:unitdate">
						<xsl:value-of select="normalize-space(.)"/>
						<xsl:if test="position() &gt; 1">
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:for-each>
					
				</xsl:if>
				<xsl:text> (</xsl:text>
				<xsl:value-of select="normalize-space(../snac:otherData/ead:did/ead:repository/ead:corpname)"/>
				<xsl:text>)</xsl:text>
				<xsl:text>&#009;</xsl:text>

				<!-- Citation-URL -->
				<xsl:value-of select="normalize-space(../snac:otherData/(ead:eadid/@url | ead:recordid/@instanceurl))"/>
				<xsl:text>&#009;</xsl:text>

				<!-- Citation-FoundData -->
				<xsl:for-each select="normalize-space(snac:rawExtract/(snac:persname | snac:corpname | snac:famname))">
					<xsl:value-of select="."/>
				</xsl:for-each>

				<!-- end of row -->
				<xsl:text>&#xA;</xsl:text>
			</xsl:for-each>

		</xsl:result-document>
	</xsl:template>


	<xsl:template name="Join-OR">
		<xsl:result-document method="text" href="{$outputFolderPath}{$tempSourceID}/{$tempSourceID}Join-Table.tsv">
			<!-- The following creates first (label) row of table -->
			<xsl:value-of select="$CPF-Source-ID-Anchor"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$CPF-Type"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$CPF-Relation-Type"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$CPF-Source-ID-Target"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$RD-Type"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$RD-Relation-Type"/>
			<xsl:text>&#009;</xsl:text>
			<xsl:value-of select="$RD-Source-ID"/>
			<xsl:text>&#xA;</xsl:text>

			<xsl:for-each select="$process/snac:oneFindingAid">


				<xsl:variable name="allEntities">
					<xsl:for-each select="snac:entity">
						<snac:entity>
							<xsl:copy-of select="@*"/>
							<xsl:copy-of select="snac:normalFinal"/>
							<xsl:copy-of select="ancestor::snac:oneFindingAid/snac:otherData/snac:eadPath"/>
							<!-- RD-role -->
							<snac:RD-role>ArchivalResource</snac:RD-role>
							<!-- RD-arcrole -->
							<xsl:choose>
								<xsl:when test="@source = 'origination'">

									<snac:RD-arcrole>creatorOf</snac:RD-arcrole>
								</xsl:when>
								<xsl:otherwise>

									<snac:RD-arcrole>referencedIn</snac:RD-arcrole>
								</xsl:otherwise>
							</xsl:choose>
							<!-- RD-Source-ID -->
							<snac:RD-Source-ID>
								<xsl:value-of select="ancestor::snac:oneFindingAid/snac:otherData/snac:eadPath"/>
							</snac:RD-Source-ID>
						</snac:entity>
					</xsl:for-each>
				</xsl:variable>


				<xsl:for-each select="snac:entity">
					<xsl:variable name="recordId">
						<xsl:value-of select="@recordId"/>
					</xsl:variable>
					<xsl:variable name="correspondedWith">
						<xsl:value-of select="@correspondent"/>
					</xsl:variable>
					<xsl:variable name="rows">
						<xsl:choose>

							<xsl:when test="(@source = 'origination') and (@controlaccessCount = '0')">
								<snac:Row>
									<snac:Source-CPFAnchor-ID>
										<xsl:value-of select="$recordId"/>
									</snac:Source-CPFAnchor-ID>
									<snac:Role/>
									<snac:ArcRole/>
									<snac:Source-CPFTarget-ID/>
								</snac:Row>
							</xsl:when>

							<xsl:when test="@source = 'origination'">
								<xsl:for-each select="$allEntities/snac:entity[not(@recordId = $recordId)]">
									<snac:Row>
										<snac:Source-CPFAnchor-ID>
											<xsl:value-of select="$recordId"/>
										</snac:Source-CPFAnchor-ID>
										<snac:Role>
											<xsl:choose>
												<xsl:when test="exists(snac:normalFinal/snac:persname)">
													<xsl:text>person</xsl:text>
												</xsl:when>
												<xsl:when test="exists(snac:normalFinal/snac:corpname)">
													<xsl:text>corporateBody</xsl:text>
												</xsl:when>
												<xsl:when test="exists(snac:normalFinal/snac:famname)">
													<xsl:text>family</xsl:text>
												</xsl:when>
											</xsl:choose>
										</snac:Role>
										<snac:ArcRole>
											<xsl:choose>
												<xsl:when test="@correspondent = 'yes'">
													<xsl:text>correspondedWith</xsl:text>
												</xsl:when>
												<xsl:otherwise>
													<xsl:text>associatedWith</xsl:text>
												</xsl:otherwise>
											</xsl:choose>
										</snac:ArcRole>
										<snac:Source-CPFTarget-ID>
											<xsl:value-of select="@recordId"/>
										</snac:Source-CPFTarget-ID>
									</snac:Row>
								</xsl:for-each>
							</xsl:when>

							<xsl:when test="@source = 'controlaccess' and @originationCount = '0'">
								<xsl:for-each select="$allEntities/snac:entity[@recordId = $recordId]">
									<snac:Row>
										<snac:Source-CPFAnchor-ID>
											<xsl:value-of select="$recordId"/>
										</snac:Source-CPFAnchor-ID>
										<snac:Role/>
										<snac:ArcRole/>
										<snac:Source-CPFTarget-ID/>
									</snac:Row>
								</xsl:for-each>
							</xsl:when>

							<xsl:when test="@source = 'controlaccess'">
								<xsl:for-each select="$allEntities/snac:entity[@source = 'origination']">
									<snac:Row>
										<snac:Source-CPFAnchor-ID>
											<xsl:value-of select="$recordId"/>
										</snac:Source-CPFAnchor-ID>
										<snac:Role>
											<xsl:choose>
												<xsl:when test="exists(snac:normalFinal/snac:persname)">
													<xsl:text>person</xsl:text>
												</xsl:when>
												<xsl:when test="exists(snac:normalFinal/snac:corpname)">
													<xsl:text>corporateBody</xsl:text>
												</xsl:when>
												<xsl:when test="exists(snac:normalFinal/snac:famname)">
													<xsl:text>family</xsl:text>
												</xsl:when>
											</xsl:choose>
										</snac:Role>
										<snac:ArcRole>
											<xsl:choose>
												<xsl:when test="$correspondedWith = 'yes'">
													<xsl:text>correspondedWith</xsl:text>
												</xsl:when>
												<xsl:otherwise>
													<xsl:text>associatedWith</xsl:text>
												</xsl:otherwise>
											</xsl:choose>
										</snac:ArcRole>
										<snac:Source-CPFTarget-ID>
											<xsl:value-of select="@recordId"/>
										</snac:Source-CPFTarget-ID>
									</snac:Row>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise> </xsl:otherwise>
						</xsl:choose>
					</xsl:variable>


					<xsl:for-each select="$rows">
						<xsl:for-each-group select="snac:Row" group-by="snac:Source-CPFAnchor-ID">
							<xsl:value-of select="current-grouping-key()"/>
							<xsl:for-each select="current-group()">
								<xsl:choose>
									<xsl:when test="position() = 1">
										<xsl:text>&#009;</xsl:text>
										<xsl:value-of select="snac:Role"/>
										<xsl:text>&#009;</xsl:text>
										<xsl:value-of select="snac:ArcRole"/>
										<xsl:text>&#009;</xsl:text>
										<xsl:value-of select="snac:Source-CPFTarget-ID"/>
										<xsl:text>&#009;</xsl:text>
										<xsl:text>ArchivalResource</xsl:text>
										<xsl:text>&#009;</xsl:text>
										<!-- RD-arcrole -->
										<xsl:value-of select="$allEntities/snac:entity[./@recordId = current-grouping-key()]/snac:RD-arcrole"/>
										<xsl:text>&#009;</xsl:text>
										<!-- RD-Source-ID -->
										<xsl:value-of select="$allEntities/snac:entity[./@recordId = current-grouping-key()]/snac:RD-Source-ID"/>
										<xsl:text>&#xA;</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>&#009;</xsl:text>
										<xsl:value-of select="snac:Role"/>
										<xsl:text>&#009;</xsl:text>
										<xsl:value-of select="snac:ArcRole"/>
										<xsl:text>&#009;</xsl:text>
										<xsl:value-of select="snac:Source-CPFTarget-ID"/>
										<xsl:text>&#xA;</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</xsl:for-each-group>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:result-document>

	</xsl:template>

	<xsl:template name="attributeNormal">
		<xsl:choose>
			<xsl:when test="@normal">
				<snac:normal type="attributeNormal">
					<xsl:element name="snac:{name()}">
						<xsl:copy-of select="@*"/>
						<xsl:value-of select="normalize-space(@normal)"/>
					</xsl:element>
				</snac:normal>
			</xsl:when>
			<xsl:otherwise>
				<snac:normal type="provisional">
					<xsl:element name="snac:{name()}">
						<xsl:copy-of select="@*"/>
						<xsl:value-of select="normalize-space(.)"/>
					</xsl:element>
				</snac:normal>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="aboutOriginationEntity">
		<xsl:param name="eadPath"/>
		<!-- This template extracts bioghist and occupation 
		-->
		<xsl:variable name="geognamesAll">
			<xsl:for-each
				select="
					ead/archdesc/controlaccess/geogname
					| ead/archdesc/controlaccess/controlaccess/geogname">
				<xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="geognameSets">
			<xsl:for-each select="$geognamesAll/geogname">
				<snac:geognameSet>
					<snac:raw>
						<xsl:copy-of select="."/>
					</snac:raw>
					<snac:normalized>
						<xsl:choose>
							<xsl:when test="contains(., '--')">
								<xsl:value-of select="normalize-space(substring-before(., '--'))"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="normalize-space(.)"/>
							</xsl:otherwise>
						</xsl:choose>
					</snac:normalized>
					<snac:normalForMatch>
						<xsl:choose>
							<xsl:when test="contains(., '--')">
								<xsl:value-of select="snac:normalizeString(substring-before(., '--'))"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="snac:normalizeString(.)"/>
							</xsl:otherwise>
						</xsl:choose>
					</snac:normalForMatch>
				</snac:geognameSet>
			</xsl:for-each>
		</xsl:variable>


		<snac:otherData>

			<snac:eadPath>
				<xsl:value-of select="snac:getFileName($eadPath)"/>
			</snac:eadPath>
			<snac:countryCode>
				<xsl:text>US</xsl:text>
			</snac:countryCode>

			<snac:languageOfDescription>
				<xsl:text>eng</xsl:text>
			</snac:languageOfDescription>

			<xsl:copy-of select="ead/eadheader/eadid | ead/control/recordid"/>

			<did xmlns="urn:isbn:1-931666-22-9">
				<xsl:for-each select="ead/archdesc/did/*">
					<xsl:copy-of select="."/>
				</xsl:for-each>
				<xsl:if test="not(ead/archdesc/did[abstract])">
					<xsl:element name="abstract">
						<xsl:value-of select="ead/archdesc/scopecontent/p[position() = 1]"/>
					</xsl:element>
				</xsl:if>
			</did>
			<xsl:call-template name="selectBioghist"/>

			<xsl:for-each select="$geognameSets">
				<xsl:for-each-group select="snac:geognameSet" group-by="snac:normalForMatch">
					<snac:geognameGroup>
						<xsl:copy-of select="./snac:normalized[1] | ./snac:normalForMatch[1]"/>
						<xsl:for-each select="current-group()">
							<xsl:copy-of select="snac:raw"/>
						</xsl:for-each>
					</snac:geognameGroup>
				</xsl:for-each-group>
			</xsl:for-each>

			<xsl:for-each
				select="
					ead/archdesc/controlaccess/(occupation | subject | function)
					| ead/archdesc/controlaccess/controlaccess/(occupation | subject | function)">
				<xsl:copy-of select="."/>
			</xsl:for-each>
		</snac:otherData>
	</xsl:template>

	<xsl:template name="selectBioghist">
		<xsl:for-each select="ead/archdesc/bioghist | ead/archdesc/bioghist/bioghist">
			<!-- The first selects a simple bioghist (neither containing or contained in another bioghist
			The second selects a bioghist that contains both a chronlist or one or more paragraphs AND does not itself contain bioghist
			The third selects those bioghist not selected by the second, in particular, or the first. 
			The otherwise filters out those bioghist/bioghist that would otherwise be matched separately.
			
			Excluded were bioghist/bioghist/bioghist as all evident were of type: .[(chronlist or p)][bioghist]
			This may have to be reconsidered.
		-->
			<xsl:choose>

				<xsl:when test=".[not(bioghist or parent::bioghist)]">
					<xsl:copy-of select="."/>
				</xsl:when>

				<xsl:when test=".[(chronlist or p)][bioghist]">
					<xsl:copy-of select="."/>
				</xsl:when>

				<xsl:when test=".[parent::bioghist[not(chronlist or p)]]">
					<xsl:copy-of select="."/>
				</xsl:when>

				<xsl:otherwise/>


			</xsl:choose>

		</xsl:for-each>
	</xsl:template>

	<xsl:template name="existDateFromPersname">
		<xsl:param name="tempString"/>

		<xsl:variable name="dateString" select="normalize-space(snac:getDateFromPersname($tempString))"/>
		<!-- takes as input a personal name string -->
		<!-- 
			snac:getDateFromPersname extracts substring from the string that matches an expected date pattern.
			Year dates can be NNN or NNNN. 
		-->

		<xsl:variable name="dateStringAnalyzeResultsOne">
			<xsl:choose>
				<xsl:when test="$dateString = '0'">
					<snac:empty/>
				</xsl:when>
				<xsl:when test="contains($dateString, '-')">
					<!-- 
						if hyphen found, creates two substrings, from and to; if not found, then a single string 
					-->
					<snac:fromString>
						<xsl:value-of select="normalize-space(substring-before($dateString, '-'))"/>
					</snac:fromString>
					<snac:toString>
						<xsl:value-of select="normalize-space(substring-after($dateString, '-'))"/>
					</snac:toString>
				</xsl:when>
				<xsl:otherwise>
					<snac:singleString>
						<xsl:value-of select="normalize-space($dateString)"/>
					</snac:singleString>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>



		<xsl:variable name="dateStringAnalyzeResultsTwo">
			<xsl:choose>
				<xsl:when test="$dateStringAnalyzeResultsOne/snac:empty">
					<snac:empty/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="$dateStringAnalyzeResultsOne/snac:fromString">
						<snac:fromDate>
							<xsl:for-each select="tokenize(., '\s')">
								<xsl:if test="matches(., 'fl\.?')">
									<snac:active/>
								</xsl:if>
								<xsl:if test="matches(., 'active')">
									<snac:active/>
								</xsl:if>
								<xsl:if test="matches(., 'ca\.?')">
									<snac:circa/>
								</xsl:if>
								<xsl:if test="matches(., '[\d]{3,4}')">
									<xsl:call-template name="createDateValueInAnalzyedDates"/>
								</xsl:if>
							</xsl:for-each>
						</snac:fromDate>
					</xsl:for-each>
					<xsl:for-each select="$dateStringAnalyzeResultsOne/snac:toString">
						<snac:toDate>
							<xsl:for-each select="tokenize(., '\s')">
								<xsl:if test="matches(., 'fl\.?')">
									<snac:active/>
								</xsl:if>
								<xsl:if test="matches(., 'active')">
									<snac:active/>
								</xsl:if>
								<xsl:if test="matches(., 'ca\.?')">
									<snac:circa/>
								</xsl:if>
								<xsl:if test="matches(., '[\d]{3,4}')">
									<xsl:call-template name="createDateValueInAnalzyedDates"/>
								</xsl:if>
							</xsl:for-each>
						</snac:toDate>
					</xsl:for-each>
					<xsl:for-each select="$dateStringAnalyzeResultsOne/snac:singleString">
						<snac:singleDate>
							<xsl:for-each select="tokenize(., '\s')">
								<xsl:if test="matches(., 'fl\.?')">
									<snac:active/>
								</xsl:if>
								<xsl:if test="matches(., 'active')">
									<snac:active/>
								</xsl:if>
								<xsl:if test="matches(., 'ca\.?')">
									<snac:circa/>
								</xsl:if>
								<xsl:if test="matches(., 'b\.?')">
									<snac:born/>
								</xsl:if>
								<xsl:if test="matches(., 'd\.?')">
									<snac:died/>
								</xsl:if>
								<xsl:if test="matches(., '[\d]{3,4}')">
									<xsl:call-template name="createDateValueInAnalzyedDates"/>
								</xsl:if>
							</xsl:for-each>
						</snac:singleDate>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!--xsl:for-each select="$dateStringAnalyzeResultsTwo">
	<xsl:message>
		<xsl:copy-of select="."></xsl:copy-of>
	</xsl:message>
</xsl:for-each-->
		<!-- Now create the existDates -->

		<xsl:choose>
			<xsl:when test="$dateStringAnalyzeResultsTwo/snac:empty"/>
			<xsl:when test="$dateStringAnalyzeResultsTwo/snac:fromDate or $dateStringAnalyzeResultsTwo/snac:toDate">
				<xsl:variable name="suspicousDateRange">
					<xsl:choose>
						<xsl:when
							test="
								$dateStringAnalyzeResultsTwo/snac:fromDate/snac:active or
								$dateStringAnalyzeResultsTwo/snac:toDate/snac:active">
							<xsl:choose>
								<xsl:when test="$dateStringAnalyzeResultsTwo/snac:toDate != ''">
									<xsl:choose>
										<xsl:when
											test="
												$dateStringAnalyzeResultsTwo/snac:fromDate/snac:normalizedValue &lt;
												$dateStringAnalyzeResultsTwo/snac:toDate/snac:normalizedValue">
											<xsl:text>yes</xsl:text>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>no</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>no</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="$dateStringAnalyzeResultsTwo/snac:toDate != ''">
							<xsl:choose>
								<xsl:when
									test="
										$dateStringAnalyzeResultsTwo/snac:fromDate/snac:normalizedValue + 15 &gt;
										$dateStringAnalyzeResultsTwo/snac:toDate/snac:normalizedValue">
									<xsl:text>yes</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>no</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>no</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<snac:existDates>
					<xsl:if test="$suspicousDateRange = 'yes'">
						<xsl:attribute name="snac:localType">
							<xsl:text>http://socialarchive.iath.virginia.edu/control/term#SuspiciousDate</xsl:text>
						</xsl:attribute>
					</xsl:if>
					<snac:dateRange>
						<xsl:for-each select="$dateStringAnalyzeResultsTwo/snac:fromDate">
							<snac:fromDate>
								<xsl:attribute name="snac:localType">
									<xsl:choose>
										<xsl:when test="snac:active">
											<xsl:text>http://socialarchive.iath.virginia.edu/control/term#Active</xsl:text>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>http://socialarchive.iath.virginia.edu/control/term#Birth</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>
								<xsl:if test="snac:circa">
									<xsl:attribute name="snac:notBefore">
										<xsl:number value="number(snac:normalizedValue) - 3" format="0001"/>
									</xsl:attribute>
									<xsl:attribute name="snac:notAfter">
										<xsl:number value="number(snac:normalizedValue) + 3" format="0001"/>
									</xsl:attribute>
								</xsl:if>
								<xsl:attribute name="snac:standardDate">
									<xsl:number value="snac:normalizedValue" format="0001"/>
								</xsl:attribute>
								<xsl:if test="snac:active">
									<xsl:text>active </xsl:text>
								</xsl:if>
								<xsl:if test="snac:circa">
									<xsl:text>approximately </xsl:text>
								</xsl:if>
								<xsl:value-of select="snac:value"/>
							</snac:fromDate>
						</xsl:for-each>

						<xsl:for-each select="$dateStringAnalyzeResultsTwo/snac:toDate">
							<xsl:choose>
								<xsl:when test=". = ''">
									<snac:toDate/>
								</xsl:when>
								<xsl:otherwise>
									<snac:toDate>
										<xsl:attribute name="snac:localType">
											<xsl:choose>
												<xsl:when test="snac:active">
													<xsl:text>http://socialarchive.iath.virginia.edu/control/term#Active</xsl:text>
												</xsl:when>
												<xsl:otherwise>
													<xsl:text>http://socialarchive.iath.virginia.edu/control/term#Death</xsl:text>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:attribute>
										<xsl:if test="snac:circa">
											<xsl:attribute name="snac:notBefore">
												<xsl:number value="number(snac:normalizedValue) - 3" format="0001"/>
											</xsl:attribute>
											<xsl:attribute name="snac:notAfter">
												<xsl:number value="number(snac:normalizedValue) + 3" format="0001"/>
											</xsl:attribute>
										</xsl:if>
										<xsl:attribute name="snac:standardDate">
											<xsl:number value="snac:normalizedValue" format="0001"/>
										</xsl:attribute>
										<xsl:if test="snac:active">
											<xsl:text>active </xsl:text>
										</xsl:if>
										<xsl:if test="snac:circa">
											<xsl:text>approximately </xsl:text>
										</xsl:if>
										<xsl:value-of select="snac:value"/>
									</snac:toDate>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>

					</snac:dateRange>
				</snac:existDates>
			</xsl:when>
			<xsl:when test="$dateStringAnalyzeResultsTwo/singleDate[born]">
				<xsl:for-each select="$dateStringAnalyzeResultsTwo/singleDate[born]">

					<snac:existDates>
						<snac:dateRange>
							<snac:fromDate localType="http://socialarchive.iath.virginia.edu/control/term#Birth">
								<xsl:if test="snac:circa">
									<xsl:attribute name="snac:notBefore">
										<xsl:number value="number(snac:normalizedValue) - 3" format="0001"/>
									</xsl:attribute>
									<xsl:attribute name="snac:notAfter">
										<xsl:number value="number(snac:normalizedValue) + 3" format="0001"/>
									</xsl:attribute>
								</xsl:if>
								<xsl:attribute name="snac:standardDate">
									<xsl:number value="snac:normalizedValue" format="0001"/>
								</xsl:attribute>
								<xsl:if test="snac:circa">
									<xsl:text>approximately </xsl:text>
								</xsl:if>
								<xsl:value-of select="snac:value"/>
							</snac:fromDate>
							<toDate/>
						</snac:dateRange>
					</snac:existDates>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$dateStringAnalyzeResultsTwo/snac:singleDate[died]">
				<xsl:for-each select="$dateStringAnalyzeResultsTwo/snac:singleDate[died]">
					<snac:existDates>
						<snac:dateRange>
							<snac:fromDate/>
							<snac:toDate localType="http://socialarchive.iath.virginia.edu/control/term#Death">
								<xsl:if test="snac:circa">
									<xsl:attribute name="snac:notBefore">
										<xsl:number value="number(snac:normalizedValue) - 3" format="0001"/>
									</xsl:attribute>
									<xsl:attribute name="snac:notAfter">
										<xsl:number value="number(snac:normalizedValue) + 3" format="0001"/>
									</xsl:attribute>
								</xsl:if>
								<xsl:attribute name="snac:standardDate">
									<xsl:number value="snac:normalizedValue" format="0001"/>
								</xsl:attribute>
								<xsl:if test="snac:circa">
									<xsl:text>approximately </xsl:text>
								</xsl:if>
								<xsl:value-of select="snac:value"/>
							</snac:toDate>
						</snac:dateRange>
					</snac:existDates>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$dateStringAnalyzeResultsTwo/snac:singleDate[active]">
				<xsl:for-each select="$dateStringAnalyzeResultsTwo/snac:singleDate[active]">
					<snac:existDates>
						<snac:dateRange>
							<snac:fromDate/>
							<snac:toDate localType="http://socialarchive.iath.virginia.edu/control/term#Active">
								<xsl:if test="circa">
									<xsl:attribute name="snac:notBefore">
										<xsl:number value="number(snac:normalizedValue) - 3" format="0001"/>
									</xsl:attribute>
									<xsl:attribute name="snac:notAfter">
										<xsl:number value="number(snac:normalizedValue) + 3" format="0001"/>
									</xsl:attribute>
								</xsl:if>
								<xsl:attribute name="snac:standardDate">
									<xsl:number value="snac:normalizedValue" format="0001"/>
								</xsl:attribute>
								<xsl:if test="snac:circa">
									<xsl:text>approximately </xsl:text>
								</xsl:if>
								<xsl:value-of select="snac:value"/>
							</snac:toDate>
						</snac:dateRange>
					</snac:existDates>
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="createDateValueInAnalzyedDates">
		<!-- goes in for-each tokenized  -->
		<xsl:choose>
			<xsl:when test="matches(., '^[\d]{4}\?$')">
				<snac:circa/>
				<snac:normalizedValue>
					<xsl:value-of select="substring-before(., '?')"/>
				</snac:normalizedValue>
				<snac:value>
					<xsl:value-of select="."/>
				</snac:value>
			</xsl:when>
			<xsl:when test="matches(., '^[\d]{3}\?$')">
				<snac:circa/>
				<snac:normalizedValue>
					<xsl:value-of select="substring-before(., '?')"/>
				</snac:normalizedValue>
				<snac:value>
					<xsl:value-of select="."/>
				</snac:value>
			</xsl:when>
			<xsl:when test="matches(., '^[\d]{4}$')">
				<snac:normalizedValue>
					<xsl:value-of select="."/>
				</snac:normalizedValue>
				<snac:value>
					<xsl:value-of select="."/>
				</snac:value>
			</xsl:when>
			<xsl:when test="matches(., '^[\d]{3}$')">
				<snac:normalizedValue>
					<xsl:value-of select="."/>
				</snac:normalizedValue>
				<snac:value>
					<xsl:value-of select="."/>
				</snac:value>
			</xsl:when>
		</xsl:choose>

	</xsl:template>


</xsl:stylesheet>
