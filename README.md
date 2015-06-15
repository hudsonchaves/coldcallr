# coldcallr

Cold call your students. They will love it!

Open coldcallr.Rmd in Rstudio and press `Run Document`. Output can be shown/hidden by clicking the black triangles.

## Cold call

Press the cold call button to select one more students to call on.

## Student list

A full list of students that can be sorted, searched, etc.

## Names

Student pictures in random order. Press the `Shuffle` button to reorder. Hover over the image to see the student's name.

## Requirements

Uses rmarkdown, shiny, and DT. As DT is not on CRAN yet install the package from rstudio/DT on github using devtools or using the command below:

`install.packages("DT", repos = "http://vnijs.github.io/radiant_miniCRAN/")`

Also requires a csv file with students names and student picture. See the content of the student-info directory for details.
