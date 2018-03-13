
require(RSelenium)
require(rvest)

condos <- read.csv("d:/condo-test-data.csv")

remDr <- remoteDriver(browserName = "chrome")
remDr$open()
remDr$navigate("http://property.phila.gov")

myresults <- data.frame()

for (i in 1:nrow(condos)){
  lastNameField <- remDr$findElement("css selector","#search-address")
  UnitField <- remDr$findElement("css selector","#search-unit")
  addr = as.character(condos[i,1]) 
  unit = as.character(condos[i,2]) 
  lastNameField$sendKeysToElement(list(addr))
  UnitField$sendKeysToElement(list(unit))
  UnitField$sendKeysToElement(list(key = 'enter'))
  Sys.sleep(3)
  website = read_html(remDr$findElement("css selector", "body")$getElementAttribute("innerHTML")[[1]])
  val = html_nodes(website,"#table-1869 > tbody > tr:nth-child(1) > td:nth-child(2) > span") %>% html_text()
  sqft = html_nodes(website,"#maincontent > div:nth-child(3) > div.property-side.large-10.columns > div.panel.mbm > div:nth-child(6) > div.medium-14.columns > strong") %>% html_text()
  thisresult <- data.frame(addr,unit,val,sqft)
  myresults <- rbind(myresults,thisresult)
  Sys.sleep(3)
  remDr$navigate("http://property.phila.gov")
}



