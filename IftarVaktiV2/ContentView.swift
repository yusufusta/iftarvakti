//
//  ContentView.swift
//  IftarVaktiV2
//
//  Created by Yusuf Usta on 18.04.2021.
//

import SwiftUI

struct ContentView: View {
    @State var sehir: String = ""
    @State var hataAlert = false
    @State var sehirAyarlandiAlert = false
    let appDelegate = NSApplication.shared.delegate as! AppDelegate

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            TextField("Şehir Adı...", text: $sehir)             .padding(.horizontal, 16.0)
                .padding(.vertical, 12.0)
                .frame(width: 300, height: 50, alignment: .topLeading)

            Button(action: {
                if (sehir == "") {
                    hataAlert = true;
                } else {
                    let defaults = UserDefaults.standard
                    defaults.set(sehir, forKey: "sehir")
                    sehirAyarlandiAlert = true
                    appDelegate.uzaktanVeriGuncellendi()
                }
            })
            {
                Text("Kaydet")
                .font(.caption)
                .fontWeight(.semibold)
            }
            .padding(.trailing, 16.0)
            .frame(width: 300, alignment: .trailing)
        }
        .padding(0)
        .frame(width: 300, height: 80, alignment: .top)
        .alert(isPresented: $hataAlert) {
            Alert(title: Text("Geçersiz İl"), message: Text("Geçersiz bir il girdiniz, tekrar deneyin."), dismissButton: .default(Text("Tamam")))
        }
        .alert(isPresented: $sehirAyarlandiAlert) {
            Alert(title: Text("Başarıyla ayarlandı!"), message: Text("İl başarılı bir şekilde ayarlandı."), dismissButton: .default(Text("Tamam")))
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
