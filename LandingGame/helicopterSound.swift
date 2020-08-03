//
//  helicopterSound.swift
//  Animation2
//
//  Created by Jan Konieczny on 02/08/2020.
//  Copyright © 2020 Jan Konieczny. All rights reserved.
//

import Foundation
import AVFoundation

var engineSound: AVAudioPlayer?

var helicopterSound: AVAudioPlayer?
let path = Bundle.main.path(forResource: "helicopterSound", ofType: "mp3")!
let helicopterSoundURL = URL(fileURLWithPath: path)


var droneSound: AVAudioPlayer?
let path2 = Bundle.main.path(forResource: "droneSound", ofType: "mp3")!
let droneSoundURL = URL(fileURLWithPath: path2)
