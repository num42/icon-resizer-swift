import AppIconResizerCore
let tool = AppIconResizer()

do {
  try tool.run()
} catch {
  print("Error occurred: \(error)")
}
