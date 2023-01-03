//import JXKit
//import JXPod
//import XCTest
//
//class CanvasPodTest : XCTestCase {
//    #if canImport(CoreGraphics)
//    func testCoreGraphicsCanvasPod() throws {
//        let properties: [String: Any] = [:]
//        let size = CGSize(width: 512, height: 512)
//        let outputData = NSMutableData()
//
//        var imageRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//
//        guard let dataConsumer = CGDataConsumer(data: outputData) else {
//            return XCTFail("no consumer")
//        }
//
//        guard let ctx = CGContext(consumer: dataConsumer, mediaBox: &imageRect, properties as NSDictionary) else {
//            return XCTFail("no context")
//        }
//
//        let pod = CoreGraphicsCanvasPod(context: ctx, size: size)
//        ctx.beginPDFPage(nil)
//
//        let jxc = JXContext()
//        let cob = jxc.object()
//        try jxc.global.setProperty("canvas", cob)
//        try pod.jack(into: cob)
//        //try pod.jxc.eval("transform(1,2,3,4,5,6)")
//
//        func metrics(_ string: String) throws -> CoreGraphicsCanvasPod.TextMetrics {
//            try jxc.global.setProperty("txt", jxc.string(string))
//            return try jxc.eval("canvas.measureText(txt)").convey()
//        }
//
//        XCTAssertEqual(24, try metrics("ABC").width, accuracy: 1.0)
//        XCTAssertEqual(99, try metrics("this is a long string").width, accuracy: 1.0)
//        XCTAssertEqual(99, try metrics("this is a long string\nwith a newline").width, accuracy: 1.0) // not naïve
//    }
//    #endif
//
//    #if canImport(CoreGraphics)
//    func testPDFCanvasPod() throws {
//        let pdf = try CoreGraphicsCanvasPod.drawPDF(size: CGSize(width: 512, height: 512)) { ctx in
//            ctx.moveTo(x: 10, y: 10)
//            ctx.lineTo(x: 20, y: 20)
//            ctx.fillRect(x: 10, y: 10, w: 20, h: 20)
//        }
//        print("created PDF size:", pdf)
//        try pdf.write(to: URL(fileURLWithPath: "/tmp/canvasdemo.pdf"))
//    }
//    #endif
//}
