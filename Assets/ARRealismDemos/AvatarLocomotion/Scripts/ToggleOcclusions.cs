//-----------------------------------------------------------------------
// <copyright file="ToggleOcclusions.cs" company="Google LLC">
//
// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// </copyright>
//-----------------------------------------------------------------------

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

/// <summary>
/// Manages occlusion effects.
/// </summary>
public class ToggleOcclusions : MonoBehaviour
{
    /// <summary>
    /// List of depth materials.
    /// </summary>
    [FormerlySerializedAs("materials")]
    public List<Material> Materials;

    /// <summary>
    /// Background effect controller.
    /// </summary>
    public BackgroundToDepthMapEffectController BackgroundEffect;

    private const float _occlusionOnOffsetMeters = 0.01f;

    private const float _occlusionOffOffsetMeters = 50.0f;

    private bool _isOcclusionOn = false;

    /// <summary>
    /// Toggles depth occlusion effect.
    /// </summary>
    /// <returns>Is occlusion on.</returns>
    public bool Toggle()
    {
        _isOcclusionOn = !_isOcclusionOn;

        if (BackgroundEffect != null)
        {
            if (_isOcclusionOn)
            {
                BackgroundEffect.StartOcclusionEffect();
            }
            else
            {
                BackgroundEffect.StartNoOcclusionEffect();
            }
        }

        return _isOcclusionOn;
    }

    private void Start()
    {
        BackgroundEffect.OcclusionChangedEvent += SwitchOcclusionMaterials;

        foreach (Material occlusionMaterial in Materials)
        {
            occlusionMaterial.SetFloat("_OcclusionOffsetMeters", _occlusionOffOffsetMeters);
        }
    }

    private void SwitchOcclusionMaterials(bool occlusionOn)
    {
        float targetValue = occlusionOn ? _occlusionOnOffsetMeters : _occlusionOffOffsetMeters;
        foreach (Material occlusionMaterial in Materials)
        {
            occlusionMaterial.SetFloat("_OcclusionOffsetMeters", targetValue);
        }
    }
}
