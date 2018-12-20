Jets.application.routes.draw do
  root "jets/rack#process"
  any "*catchall", to: "jets/rack#process"
end
