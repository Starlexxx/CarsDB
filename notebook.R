---
title: "R Notebook"
output: html_notebook
---

initialization
```{r include = FALSE}
library(odbc)
library(tidyr)
library(purrr)
con <- dbConnect(odbc::odbc(), "PG edu")
```


```{r}
library(ggplot2)
dbGetQuery(con,'
select c.color, count(p.person_id)
from people p
         join cars_owners co on p.person_id = co.person_id
         join cars c on c.car_id = co.car_id
where p.sex = \'female\'
group by c.color;
') %>%
  ggplot(aes(x=color, y=as.integer(count), fill=color))+ geom_bar(stat="identity")
```


```{r}
library(ggplot2)
dbGetQuery(con,'
select p.sex, avg(co.start_mileage) as average_start_mileage
from people p
         join cars_owners co on p.person_id = co.person_id
where co.start_date > \'2021-05-03\'
group by p.sex;
') %>%
  ggplot(aes(x=sex, y=average_start_mileage, fill=sex)) + geom_bar(stat="identity")
```
