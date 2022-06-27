//
//  ContentView.swift
//  WikipediaScraper
//
//  Created by user on 24/06/22.
//

import SwiftUI
import Foundation
import UIKit
import WebKit
import RichText


struct ContentView: View {
    @State var immagine: Image = Image("png.monster-515")
    @State var risultatiScraping: [(String, Int, String)] = randomPageParsed()
    @State var qrCode: Image = Image("")
    @State var titolo: Text = Text("Titolo: ")
    
    @State var htmlView: RichText = RichText(html: "Ciao")
    
    var body: some View {
        ZStack{
        
        ScrollView{
        immagine
            .resizable()
            .scaledToFit()
            .aspectRatio(contentMode: .fit)
            .frame(width: 350, height: 350)
            
            
        titolo
            .padding()
            .foregroundColor(.black)
        qrCode
            .resizable()
            .scaledToFit()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200)
        
        Button("Genera Nuovo") {
            risultatiScraping = randomPageParsed()
            qrCode = Image(uiImage: UIImage(data: getQRCodeDate(text: "https://it.wikipedia.org/wiki/\(risultatiScraping[0].2)")!)!)
            titolo = Text("Title: \(risultatiScraping[0].2)")
            htmlView = RichText(html: risultatiScraping[1].2)
        }
        
        htmlView
            .placeholder {
                Text("loading")
            }
            .foregroundColor(.black)
    }
        }.background(Color(red: 244 / 255, green: 255 / 255, blue: 248 / 255))
}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func randomPageParsed() -> [(String, Int, String)] {
    let url = URL(string: "https://it.wikipedia.org/wiki/Speciale:PaginaCasuale")!
    let html = try! String(contentsOf: url)
    return pageParser(html)
}

func pageParser(_ htmlPage: String) -> [(String, Int, String)] {
    var output: [(String, Int, String)] = []
    let splitted = htmlPage.split(separator: "\n")
    var counterTitle: Int = 0
    var counterParagraph: Int = 0
    
    for i in 0..<splitted.count {
        if splitted[i].contains("<title>") {
            output.append(("title",
                           counterTitle,
                           String(splitted[i].suffix(splitted[i].count - 7).prefix(splitted[i].count - 27))))
            counterTitle += 1
        }
        
        if splitted[i].contains("<p>") {
            output.append(("p",
                           counterParagraph,
                           String(splitted[i])))
            counterParagraph += 1
        }
    }
    
    print("Output: \(output)")
    
    return output
}

func getQRCodeDate(text: String) -> Data? {
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    let data = text.data(using: .ascii, allowLossyConversion: false)
    filter.setValue(data, forKey: "inputMessage")
    guard let ciimage = filter.outputImage else { return nil }
    let transform = CGAffineTransform(scaleX: 10, y: 10)
    let scaledCIImage = ciimage.transformed(by: transform)
    let uiimage = UIImage(ciImage: scaledCIImage)
    return uiimage.pngData()!
}
