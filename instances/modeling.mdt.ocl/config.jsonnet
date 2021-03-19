{
  project+: {
    fullName: "modeling.mdt.ocl",
    displayName: "Eclipse OCL"
  },
  deployment+: {
    cluster: "okd-c1",
  },
  jenkins+: {
    theme: "quicksilver-light",
    plugins+: [
      "buckminster",
    ],
  } 
}
