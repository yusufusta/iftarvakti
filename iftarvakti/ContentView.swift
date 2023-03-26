//
//  ContentView.swift
//  iftarvakti
//
//  Created by Yusuf Usta on 24.03.2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var menuVM: MenuAppViewModel

    @State var todayVakit : Vakit? = nil
    
    @AppStorage("topBarStyle") var topBarStyle: String = "saatKisa"

    @AppStorage("selectedIl") var selectedIl: String = "539"
    @AppStorage("selectedIlce") var selectedIlce: String = "9550"

    @AppStorage("selectedIlStr") var selectedIlStr: String = "İSTANBUL"
    @AppStorage("selectedIlceStr") var selectedIlceStr: String = "SULTANGAZİ"

    @State private var selectShowLabel = true

    @State private var ilceler : Ilceler = [Ilce(IlceID: "0", IlceAdi: "İl Seçiniz", IlceAdiEn: "İl Seçiniz")]
    
    var topBarStyles: Array = [
        ["saatUzun", "Saat sa:Dakika dk:Saniye sn"],
        ["saatKisa", "Saat:Dakika:Saniye"],
        ["saatTurUzun", "İftar | Saat sa:Dakika dk:Saniye sn"],
        ["saatTurKisa", "Sahur | Saat:Dakika:Saniye"],
        ["dakikaUzun", "Saat sa:Dakika dk"],
        ["dakikaKisa", "Saat:Dakika"],
        ["boslukluUzun", "Saat sa Dakika dk Saniye sn"],
        ["boslukluKisa", "Saat Dakika"],
        ["sehirIlceKisa", "Şehir İlçe | Saat:Dakika"],
        ["ilceTurUzun", "İlçe | Sahur | Saat:Dakika:Saniye"],
        ["kisaTur", "i | Sahur"],
        ["kisa", "i"],
    ]
    var api = Api()
    
    
    var body: some View {
        VStack {
            ZStack{
                HStack{
                    Image(systemName: menuVM.vakitTur == 0 ? "moon.fill":"sun.max.fill").imageScale(.large)
                    Spacer()
                }
                
                
                HStack{
                    Spacer()
                    if todayVakit != nil {
                        let date = menuVM.vakitTur == 0 ? (todayVakit?.aksam ?? "") :(todayVakit?.imsak ?? "")
                        Text("\(date) | \(todayVakit?.hicriTarihUzun ?? "")")
                    }
                }
            }
            
            Group {
                
                HStack{
                    Text("\(selectedIlceStr), \(selectedIlStr)")
                }.padding(.top, 1)
                
                Divider()
            }
            
            Group {
                
                VStack{
                    Text((menuVM.vakitTur == 0 ? "İftara" : "Sahura") + " Kalan Süre:")
                    Text(menuVM.kalanSureApp).font(.system(size: 32))
                    
                }.padding(.top, 17)
                
                
                
                Divider()
            }
            
            Group {
                
                HStack{
                    Picker("İl", selection: $selectedIl) {
                        Text("Lütfen Seçiniz...").tag("");
                        
                        ForEach(menuVM.iller, id: \.self) {
                            Text($0.SehirAdi).tag($0.SehirID)
                        }
                    }
                    .onChange(of: selectedIl) { tag in
                        for il in menuVM.iller {
                            if il.SehirID == tag {
                                selectedIlStr = il.SehirAdi
                            }
                        }
                        
                        api.getIlceler(ilId: tag) { ilceler in
                            self.ilceler = ilceler;
                        }
                    }
                    
                    Picker("İlçe", selection: $selectedIlce) {
                        ForEach(ilceler, id: \.self) {
                            Text($0.IlceAdi).tag($0.IlceID)
                        }
                    }.onChange(of: selectedIlce) { tag in
                        for ilce in ilceler {
                            if ilce.IlceID == tag {
                                selectedIlceStr = ilce.IlceAdi
                            }
                        }
                        
                        menuVM.run()
                    }
                }
                
                HStack{
                    Picker("Menü Türü", selection: $topBarStyle) {
                        ForEach(topBarStyles, id: \.self) {
                            Text($0[1]).tag($0[0])
                        }
                    }.onChange(of: topBarStyle) { tag in
                    }
                }
                
                Divider()
            }
            Group {
                
                HStack{
                    Button("Yenile") {
                        menuVM.run()
                    }
                    
                    Button("Kapat") {
                        exit(-1)
                    }
                }
                
                HStack {
                    Text("[GitHub](https://github.com/yusufusta/iftarvakti)").font(.system(size: 9))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("[yusufusta.dev](https://yusufusta.dev)").font(.system(size: 9))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

            }
        }
        .onAppear {
            menuVM.run()
            
            if (selectedIl != "") {
                api.getIlceler(ilId: selectedIl) { ilceler in
                    self.ilceler = ilceler;
                }
            }
            
            if (selectedIlce != "") {
                api.getVakitler(ilceId: selectedIlce) {
                    vakitler in
                    todayVakit = menuVM.getTodayVakit(vakitler: vakitler) ?? nil;
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
