//
//  ContentView.swift
//  Amination
//
//  Created by Jan Konieczny on 20/07/2020.
//  Copyright © 2020 Jan Konieczny. All rights reserved.
//

import SwiftUI
import CoreMotion
import SpriteKit
import AVFoundation

extension UIScreen{
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}

struct ContentView: View {
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    
    let helicopterSpeed: CGFloat = 8
    let droneSpeed: CGFloat = 50
    
    let helicopterSize: CGFloat = 150
    let landingPadSize: CGFloat = 130
    let isCloseToLandingPadPrecise: CGFloat = 70
    
    @State private var landingPrecision: CGFloat = 10
    @State private var changeHelicopterToDrone: Bool = false
    @State private var accelerometerIsOn: Bool = false
    @State private var devicePitch = Double.zero
    @State private var deviceRoll = Double.zero
    @State private var deviceYaw = Double.zero
    
    @State private var helicopterPosition: CGSize = .zero
    @State private var landingPadPosition: CGSize = .zero
    
    
    @State private var isEngineSoundOn: Bool = true
    @State private var isLanded: Bool = false
    @State private var isLandingScale: CGFloat = 1
    @State private var flightSpeed: CGFloat = 8
    @State private var currentFlightMachine: String = "helicopter"
    
    @State private var userPoints = 0
    @State private var pointsOpacity: Double = 0.0
    @State private var pointAnimationAmount = 0.0
    @State private var showingAlert = false
    
    var screenWidthBound: CGFloat {
        UIScreen.screenWidth / 2 - helicopterSize / 2
    }
    var screenHeightBound: CGFloat {
        UIScreen.screenHeight / 2 - helicopterSize / 2
    }
    
    var body: some View {
        VStack {
            Spacer()
            ZStack{
                Image("pad")
                    .resizable()
                    .frame(width: (self.landingPadSize), height: (self.landingPadSize), alignment: .center)
                    .offset(x: self.landingPadPosition.width, y: self.landingPadPosition.height)
                    .animation(.easeInOut(duration: 2))
                
                Image(currentFlightMachine)
                    .resizable()
                    .frame(width: self.helicopterSize, height: self.helicopterSize, alignment: .center)
                    .scaleEffect(self.isLandingScale, anchor: .center)
                    .rotationEffect(.radians(self.deviceRoll * 1.5), anchor: .center)
                    .offset(x: (self.helicopterPosition.width), y: (self.helicopterPosition.height))
                    .animation(.easeInOut(duration: 2))
                
                LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .topLeading, endPoint: .bottomLeading)
                    .frame(width: 90, height: 90, alignment: .center)
                    .clipShape(Circle())
                    .overlay(
                        Text(self.currentFlightMachine == "helicopter" ? "+1" : "+2")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                )
                    .opacity(self.pointsOpacity)
                    .rotation3DEffect(.degrees(self.pointAnimationAmount), axis: (x: 0, y: 1, z: 0))
                    .animation(Animation.easeInOut(duration: 1))
            }
            Spacer()
            HStack(){
                Spacer()
                Text("\(userPoints)")
                    .fontWeight(.semibold)
                Spacer()
                Button(action: {
                    self.showingAlert = true
                    //self.restartGame()
                }) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .frame(width: 20, height: 20, alignment: .center)
                        .padding(.all, 5)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(20)
                }
                .alert(isPresented:$showingAlert) {
                    Alert(title: Text("Are you sure you want to restart game?"), primaryButton: .destructive(Text("Restart")) {
                        self.motionManager.stopDeviceMotionUpdates()
                        self.restartGame()
                        }, secondaryButton: .cancel())
                }
                Spacer()
                Button(action: {
                    self.changeHelicopterToDrone.toggle()
                    self.currentFlightMachine = self.changeHelicopterToDrone ? "drone" : "helicopter"
                    self.landingPrecision = self.changeHelicopterToDrone ? 1 : 10
                    self.startSound()
                }) {
                    if self.changeHelicopterToDrone {
                        Image("helicopterSymbol")
                            .resizable()
                            .frame(width: 40, height: 40, alignment: .center)
                            
                    } else {
                        Image("droneSymbol")
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .center)
                            .padding(.top, 8)
                            .padding(.bottom, 7)
                            .padding(.trailing, 7.5)
                            .padding(.leading, 7.5)
                    }
                    
                }
                Spacer()
                Button(action: {
                    self.isEngineSoundOn.toggle()
                    self.startSound()
                }) {
                    
                    if self.isEngineSoundOn {
                        Image(systemName: "speaker.2.fill")
                        
                    } else {
                        Image(systemName: "speaker.slash.fill")
                            .foregroundColor(Color.gray)
                            .padding(.leading, 4)
                    }
                }
                Spacer()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 20, maxHeight: 20, alignment: .bottom)
            .padding(.bottom, 15)
            .padding(.top, 0)
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            self.startGame()
        }
        
        
    }
    
    func startGame() {
        self.randomizePosition(of: &helicopterPosition)
        self.randomizePosition(of: &landingPadPosition)
        self.flightSpeed = self.currentFlightMachine == "helicopter" ? self.helicopterSpeed : self.droneSpeed
        self.startAccelerometer()
        self.startSound()
        
    }
    
    func startSound(){
        if isEngineSoundOn{
            do {
                engineSound = try AVAudioPlayer(contentsOf: (changeHelicopterToDrone ? droneSoundURL : helicopterSoundURL))
            } catch {
                print("Error")
            }
            engineSound?.play()
        } else {
            engineSound?.pause()
        }
    }
    
    func stopSound(){
        helicopterSound?.pause()
        droneSound?.pause()
    }
    
    func restartGame() {
        self.userPoints = 0
        self.startGame()
    }
    
    func randomizePosition(of gameElementView: inout CGSize){
        gameElementView.height = CGFloat.random(in: -screenHeightBound ... screenHeightBound)
        gameElementView.width = CGFloat.random(in: -screenWidthBound ... screenWidthBound)
    }
    
    func correctPosition(of gameElementView: inout CGSize) {
        if gameElementView.width > screenWidthBound {
            gameElementView.width = screenWidthBound
        }
        if gameElementView.height > screenHeightBound {
            gameElementView.height = screenHeightBound
        }
        if gameElementView.width < -screenWidthBound {
            gameElementView.width = -screenWidthBound
        }
        if gameElementView.height < -screenHeightBound + 20 {
            gameElementView.height = -screenHeightBound + 20
        }
    }
    
    func isCloseToLandingPad() {
        if ((self.helicopterPosition.width < self.landingPadPosition.width + self.isCloseToLandingPadPrecise) && (self.helicopterPosition.width > self.landingPadPosition.width - self.isCloseToLandingPadPrecise)) &&  ((self.helicopterPosition.height < landingPadPosition.height + self.isCloseToLandingPadPrecise) && (self.helicopterPosition.height > landingPadPosition.height - self.isCloseToLandingPadPrecise)){
            self.isLandingScale = 0.7
            self.flightSpeed = self.currentFlightMachine == "helicopter" ? 2 : 20
            helicopterSound?.setVolume(Float(isLandingScale), fadeDuration: 2)
        } else {
            self.isLandingScale = 1
            self.flightSpeed = self.currentFlightMachine == "helicopter" ? self.helicopterSpeed : self.droneSpeed
            engineSound?.setVolume(Float(isLandingScale), fadeDuration: 2)
        }
    }
    
    func isLandedOnPad() {
        if ((self.helicopterPosition.width < self.landingPadPosition.width + self.landingPrecision) && (self.helicopterPosition.width > self.landingPadPosition.width - self.landingPrecision)) &&  ((self.helicopterPosition.height < landingPadPosition.height + self.landingPrecision) && (self.helicopterPosition.height > landingPadPosition.height - self.landingPrecision)){
            
            self.isLanded = true
            engineSound?.setVolume(0.2, fadeDuration: 2)
            
            self.userPoints += self.currentFlightMachine == "helicopter" ? 1 : 2
            withAnimation {
                self.pointAnimationAmount += 360
                self.pointsOpacity = 1
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.pointsOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.isLandingScale = 1
                self.isLanded = false
                engineSound?.setVolume(1, fadeDuration: 1.5)
                self.randomizePosition(of: &self.landingPadPosition)
            }
            
        }
    }
    
    func startAccelerometer(){
        self.motionManager.startDeviceMotionUpdates(to: self.queue) { (data: CMDeviceMotion?, error: Error?) in
            guard let data = data else {
                print("Error: \(error!)")
                return
            }
            let attitude: CMAttitude = data.attitude
            if self.showingAlert == false {
                if self.isLanded == false {
                    DispatchQueue.main.async {
                        self.devicePitch = attitude.pitch
                        self.deviceRoll = attitude.roll
                        
                        self.helicopterPosition.width = self.helicopterPosition.width + CGFloat(attitude.roll) * self.flightSpeed
                        self.helicopterPosition.height = self.helicopterPosition.height + CGFloat(attitude.pitch) * self.flightSpeed
                        self.correctPosition(of: &self.helicopterPosition)
                        
                        self.isCloseToLandingPad()
                        self.isLandedOnPad()
                    }
                }
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
