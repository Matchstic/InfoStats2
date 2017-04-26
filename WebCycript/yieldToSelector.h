/* Cydget - open-source AwayView plugin multiplexer
 * Copyright (C) 2008-2011  Jay Freeman (saurik)
*/

/* GNU General Public License, Version 3 {{{ */
/*
 * Cydget is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * Cydget is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Cydget.  If not, see <http://www.gnu.org/licenses/>.
**/
/* }}} */

#ifndef Cydget_yieldToSelector_H
#define Cydget_yieldToSelector_H

#include <Foundation/Foundation.h>

@interface NSObject (MenesYieldToSelector)
- (id) cydget$yieldToSelector:(SEL)selector withObject:(id)object;
- (id) cydget$yieldToSelector:(SEL)selector;
@end

#endif//Cydget_yieldToSelector_H
