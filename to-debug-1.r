
require(RSelenium)
require(rvest)

condos <- read.csv("d:/condo-test-data.csv")

remDr <- remoteDriver(browserName = "chrome")
remDr$open()
remDr$navigate("http://property.phila.gov")

myresults <- data.frame()

for (i in 1:nrow(condos)){
  
  addressField <- remDr$findElement("css selector", "#search-address")
  unitField <- remDr$findElement("css selector", "#search-unit")
  addr<- condos$address
  unit <- condos$unit
  addressField$sendKeysToElement(list(addr))
  unitField$sendKeysToElement(list(unit))
  addressField$sendKeysToElement(list(key = 'submit'))
  
  Sys.sleep(2)
  
  website = read_html(remDr$findElement("css selector", "html")$getElementAttribute("innerHTML")[[1]])

  val <- html_nodes(website,".tablesaw-stack > tbody > tr") %>% html_text()
  sqft <- html_nodes(website, "#maincontent > div:nth-child(3)")%>% html_text()

  remDr$goBack()
  Sys.sleep(2)
  
  thisresult <- data.frame(addr,unit,val,sqft)
  myresults <- rbind(myresults,thisresult)
  
}



