/* -*- Mode: C++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4; fill-column: 100 -*- */
/*
 * This file is part of the LibreOffice project.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * This file incorporates work covered by the following license notice:
 *
 *   Licensed to the Apache Software Foundation (ASF) under one or more
 *   contributor license agreements. See the NOTICE file distributed
 *   with this work for additional information regarding copyright
 *   ownership. The ASF licenses this file to you under the Apache
 *   License, Version 2.0 (the "License"); you may not use this file
 *   except in compliance with the License. You may obtain a copy of
 *   the License at http://www.apache.org/licenses/LICENSE-2.0 .
 */

#include <sal/config.h>
#include <sal/log.hxx>

#include <cassert>
#include <cstring>
#include <numeric>

#include <basegfx/polygon/b2dpolygon.hxx>
#include <basegfx/polygon/b2dpolygontools.hxx>
#include <basegfx/polygon/b2dpolypolygontools.hxx>
#include <osl/endian.h>
#include <osl/diagnose.h>
#include <osl/file.hxx>
#include <sal/types.h>
#include <tools/long.hxx>
#include <vcl/sysdata.hxx>

#include <quartz/salbmp.h>
#include <quartz/utils.h>
#ifdef IOS
#include <svdata.hxx>
#endif

using namespace vcl;

SystemGraphicsData AquaSalGraphics::GetGraphicsData() const
{
    SystemGraphicsData aRes;
    aRes.nSize = sizeof(aRes);
    aRes.rCGContext = maShared.maContextHolder.get();
    return aRes;
}

void AquaSharedAttributes::setState()
{
    maContextHolder.restoreState();
    maContextHolder.saveState();

    // setup clipping
    if (mxClipPath)
    {
        CGContextBeginPath(maContextHolder.get());            // discard any existing path
        CGContextAddPath(maContextHolder.get(), mxClipPath);  // set the current path to the clipping path
        CGContextClip(maContextHolder.get());                 // use it for clipping
    }

    // set RGB colorspace and line and fill colors
    CGContextSetFillColor(maContextHolder.get(), maFillColor.AsArray() );

    CGContextSetStrokeColor(maContextHolder.get(), maLineColor.AsArray() );
    CGContextSetShouldAntialias(maContextHolder.get(), false );
    if (mnXorMode == 2)
    {
        CGContextSetBlendMode(maContextHolder.get(), kCGBlendModeDifference );
    }
}

XorEmulation::XorEmulation()
  : m_xTargetLayer( nullptr )
  , m_xTargetContext( nullptr )
  , m_xMaskContext( nullptr )
  , m_xTempContext( nullptr )
  , m_pMaskBuffer( nullptr )
  , m_pTempBuffer( nullptr )
  , m_nBufferLongs( 0 )
  , m_bIsEnabled( false )
{
    SAL_INFO( "vcl.quartz", "XorEmulation::XorEmulation() this=" << this );
}

XorEmulation::~XorEmulation()
{
    SAL_INFO( "vcl.quartz", "XorEmulation::~XorEmulation() this=" << this );
    Disable();
    SetTarget( 0, 0, 0, nullptr, nullptr );
}

/* vim:set shiftwidth=4 softtabstop=4 expandtab: */
