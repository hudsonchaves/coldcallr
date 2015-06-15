# coldcallr

Cold call your students. They will love it!

See an example in action at <a href="https://vnijs.shinyapps.io/coldcallr/coldcallr.Rmd" target="_blank">https://vnijs.shinyapps.io/coldcallr/coldcallr.Rmd</a> 

To run locally, copy the repo to your computer, open `coldcallr.Rmd` in Rstudio, and press `Run Document`. Output can be shown/hidden by clicking the black triangles.

## Cold call

Press the cold call button to select one more students to call on.

## Student list

A full list of students that can be sorted, searched, etc.

## Names

Student pictures in random order. Press the `Shuffle` button to reorder. Hover over the image to see the student's name.

## Requirements

Uses rmarkdown, shiny, dplyr, and DT. See `coldcallr.R` for all packages used. DT is not on CRAN so install the package from rstudio/DT on github using devtools or the command below:

`install.packages("DT", repos = "http://vnijs.github.io/radiant_miniCRAN/")`

Also requires a csv file with students names and student picture. See the content of the student-info directory for details.

## Images from ...

<a href="http://www.huffingtonpost.com/2014/06/09/fairytale-mugshots_n_5475538.html" target="_blank">fairytale-mugshots</a>

<a href="http://thefw.com/cartoon-character-mugshots/" target="_blank">cartoon-character-mugshots</a>
