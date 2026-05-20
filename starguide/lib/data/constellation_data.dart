import 'package:flutter/material.dart';

import '../models/star.dart';
import '../models/constellation.dart';
import '../models/constellation_edge.dart';


const List<Constellation> constellations = [
  Constellation(
    id: 'lyra',
    name: 'こと座',
    description: '夏の代表的な星座の一つです',
    stars: [
      Star(
        id: 'vega', 
        name: 'ベガ', 
        x: 120, 
        y: 80, 
        brightness: 1.0, 
        color: Colors.white,
      ),
      Star(
        id: 'lyra_2', 
        name: 'こと座星2', 
        x: 180, 
        y: 140, 
        brightness: 0.7, 
        color: Colors.white,
      )
    ],
    edges: [
      ConstellationEdge(
        fromStarId: 'vega', toStarId: 'lyra_2'
      ),
    ],
  ),
];