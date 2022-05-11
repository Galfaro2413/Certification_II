*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium
Library           Collections
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.Excel.Files
Library           Telnet
Library           Process
Library           RPA.Robocloud.Items
Library           RPA.PDF
Library           OperatingSystem
Library           RPA.Archive
Library           RPA.FileSystem
Library           RPA.Robocloud.Secrets


*** Variables ***
${URL}=           https://robotsparebinindustries.com/#/robot-order
${Receipt}=       Receipt
${.pdf}=          .pdf
${OUTPUT_DIRECTORY}=    ${CURDIR}${/}output

*** Keywords ***
Open the intranet website
    Open Available Browser    ${URL}   

*** Keywords ***
Download Order CSV file
    ${secret}=    Get Secret    CSV_File
    Download   ${secret}[CSV_File]     overwrite=True

*** Keywords ***
Get Orders
    ${orders}=   Read Table From Csv    orders.csv                        
    FOR    ${row}    IN    @{orders}
        Close PopUp Modal
        Fill the form  ${row}
        Preview the robot
        Wait Until Keyword Succeeds    5x    6s     Submit the order
        ${pdf}=   Store the receipt as a PDF file    ${row}[Order number] 
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END

*** Keywords ***
Close PopUp Modal
    Click Button    OK
    Wait Until Element Is Visible    head

*** Keywords ***
Fill the form
    [Arguments]    ${row}
    Select From List By Value    head   ${row}[Head]
    IF    ${row}[Body] == 1
        Select Radio Button    body    1 
    ELSE
        IF    ${row}[Body] == 2
            Select Radio Button    body    2
    ELSE
          IF    ${row}[Body] == 3
              Select Radio Button    body    3
      ELSE
              IF    ${row}[Body] == 4
                  Select Radio Button    body    4
          ELSE
                 IF    ${row}[Body] == 5
                     Select Radio Button    body    5
             ELSE
                Select Radio Button    body    6 
             END 
          END
      END  
    END
    END     
    Input Text   css:input[Class="form-control"]   ${row}[Legs]  
    Input Text    address    ${row}[Address]

*** Keywords ***
Preview the robot 
    Click Button    Preview
    Wait Until Page Contains Element    robot-preview-image

*** Keywords ***
Submit the order
    Click Button    Order
    Wait Until Page Contains Element    receipt   
       
*** Keywords ***
Store the receipt as a PDF file 
    [Arguments]    ${row}
    ${sales_results_html}=    Get Element Attribute    receipt    outerHTML
    Html To Pdf    ${sales_results_html}    ${CURDIR}${/}output${/}${Receipt}${row}${.pdf}
    [Return]    ${CURDIR}${/}output${/}${Receipt}${row}${.pdf}

*** Keywords ***
Take a screenshot of the robot
    [Arguments]    ${row}
    Sleep    1
    Screenshot    css:div[class="container main-container"]    ${CURDIR}${/}output${/}Screenshot${row}.png
    [Return]   ${CURDIR}${/}output${/}Screenshot${row}.png
*** Keywords ***
Embed the robot screenshot to the receipt PDF file
   [Arguments]      ${screenshot}   ${pdf}
   Open Pdf  ${pdf}
   Add Watermark Image To Pdf    ${screenshot}    ${pdf} 
   Close All Pdfs 

*** Keywords ***
Go to order another robot
    Click Button    Order another robot


*** Keywords ***
Create a ZIP file of the receipts
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIRECTORY}/PDFs.zip
    Archive Folder With Zip   ${OUTPUT_DIRECTORY}     ${zip_file_name}   include=*.pdf  exclude=/.*

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Download Order CSV file
    Open the intranet website    
    Get Orders
    Create a ZIP file of the receipts