\name{multiplyTwoNumbers}

\alias{multiplyTwoNumbers}
\title{Add two numbers}

\description{
    An example function that can be made into a Galaxy tool.
    Takes two numbers, multiplies them, and returns a file containing
    the result.
}

\usage{
multiplyTwoNumbers(number1=GalaxyNumericParam(required=TRUE),
        number2=GalaxyNumericParam(required=TRUE),
        product=GalaxyOutput("product", "txt"))
}

\arguments{
  \item{number1}{
    The first number to multiply.
  }
  \item{number2}{
    The second number to mutiply.
  }
  \item{sum}{
    Where the result of the multiplication should be written.
  }
}

\value{
  invisible(NULL)
}

\seealso{
    \code{\link{galaxy}}, 
    \code{\link{GalaxyConfig}}, \code{\link{GalaxyOutput}},
    \code{\link{multiplyTwoNumbers}}

}

\examples{
t <- tempfile()
multiplyTwoNumbers(2, 2, t)
readLines(t, warn=FALSE)
}

